#!/bin/bash
#
# Snapshots the btrfs mongodb storage for the instance running the pre-parser.

# Assuming snapshots being taken every hour, this will keep seven days worth:
MAX_SNAPSHOTS_COUNT=$((7*24))

. /root/scripts/shared.inc

[[ "$RUNS_MONGO" != "true" ]] && echo "This instance does not run mongo" && exit 0

# Assume all goes well:
EXIT_CODE=0
OUTPUTCAP=/tmp/snapshot-mongodb-storage.out
rm -f $OUTPUTCAP

SNAPSHOT="/mongodb/snap.$(date +%F.%H%M)"

echo "Snapshotting /mongodb/current as $SNAPSHOT ..." | tee $OUTPUTCAP

btrfs subvolume snapshot /mongodb/current $SNAPSHOT 2>&1 | tee -a $OUTPUTCAP
if [[ "${PIPESTATUS[0]}" = "0" ]]; then
    echo "Snapshot created, looking for old snapshot(s) to prune ..." | tee -a $OUTPUTCAP
    
    SNAPSHOTS_COUNT=$(ls /mongodb/|grep snap|wc -l)
    
    if [[ $MAX_SNAPSHOTS_COUNT -lt $SNAPSHOTS_COUNT ]]; then
        
        REMOVE_COUNT=$((SNAPSHOTS_COUNT-MAX_SNAPSHOTS_COUNT))
        
        echo "Removing $REMOVE_COUNT snapshot(s) ..." | tee -a $OUTPUTCAP
        
        for KILLSHOT in $(ls /mongodb/|grep snap|sort|head -n $REMOVE_COUNT); do
            echo "Removing $KILLSHOT ..." | tee -a $OUTPUTCAP
            
            btrfs subvolume delete /mongodb/$KILLSHOT 2>&1 | tee -a $OUTPUTCAP
            
            [[ "${PIPESTATUS[0]}" != "0" ]] && echo "Failed" && EXIT_CODE=1
        done
    fi
fi

[[ $EXIT_CODE != 0 ]] && shout "Failure while snapshotting mongodb btrfs storage" "Captured output: $NL2$(cat $OUTPUTCAP)"

rm -f $OUTPUTCAP

exit $EXIT_CODE
