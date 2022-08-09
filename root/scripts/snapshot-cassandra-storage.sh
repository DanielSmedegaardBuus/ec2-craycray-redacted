#!/bin/bash
#
# Snapshots the btrfs cassandra storage on /mnt, creating both a cassandra snap
# and a btrfs one, named "snap.YYYY-MM-DD.HHmm".
# 
# Before flushing and doing a cassandra snapshot, existing ones are removed.
# 
# After have snapped cassandra, a btrfs snapshot is taken, and old btrfs snaps
# are deleted once MAX_SNAPSHOTS_COUNT have been taken.

# Assuming snapshots are taken every hour, this will keep just one day's worth
# (these snapshots can get quite large):
MAX_SNAPSHOTS_COUNT=$((1*24))

. /root/scripts/shared.inc

[[ "$RUNS_CASSANDRA" != "true" ]] && echo "This instance does not run cassandra" && exit 0

# Capture script output to temporary file in case we fail and need to report:
OUTPUTCAP=/tmp/snapshot-cassandra-storage.out
echo "Snapshotting cassandra storage ..." | tee $OUTPUTCAP

SNAPSHOT="snap.$(date +%F.%H%M)"

do_fail()
{
    echo "Failed" | tee -a $OUTPUTCAP
    shout "Failure while snapshotting mongodb btrfs storage" "Captured output: $NL2$(cat $OUTPUTCAP)"
    rm -f $OUTPUTCAP
    exit 1
}

echo "Clearing existing cassandra snapshots ..." | tee -a $OUTPUTCAP
nodetool clearsnapshot 2>&1 | tee -a $OUTPUTCAP
[[ "${PIPESTATUS[0]}" != "0" ]] && do_fail

echo "Flushing node ..." | tee -a $OUTPUTCAP
nodetool flush 2>&1 | tee -a $OUTPUTCAP
[[ "${PIPESTATUS[0]}" != "0" ]] && do_fail

echo "Creating cassandra snapshot ..." | tee -a $OUTPUTCAP
nodetool snapshot -t $SNAPSHOT 2>&1 | tee -a $OUTPUTCAP
[[ "${PIPESTATUS[0]}" != "0" ]] && do_fail

echo "Taking btrfs snapshot /mnt/$SNAPSHOT ..." | tee -a $OUTPUTCAP
btrfs subvolume snapshot /mnt/cassandra /mnt/$SNAPSHOT 2>&1 | tee -a $OUTPUTCAP
[[ "${PIPESTATUS[0]}" != "0" ]] && do_fail

echo "Looking for old btrfs snapshot(s) to prune ..." | tee -a $OUTPUTCAP

SNAPSHOTS_COUNT=$(ls /mnt/|grep snap|wc -l)

if [[ $MAX_SNAPSHOTS_COUNT -lt $SNAPSHOTS_COUNT ]]; then
    
    REMOVE_COUNT=$((SNAPSHOTS_COUNT-MAX_SNAPSHOTS_COUNT))
    
    echo "Removing $REMOVE_COUNT btrfs snapshot(s) ..." | tee -a $OUTPUTCAP
    
    for KILLSHOT in $(ls /mnt/|grep snap|sort|head -n $REMOVE_COUNT); do
        echo "Removing $KILLSHOT ..." | tee -a $OUTPUTCAP
        btrfs subvolume delete /mnt/$KILLSHOT 2>&1 | tee -a $OUTPUTCAP
        [[ "${PIPESTATUS[0]}" != "0" ]] && do_fail
    done
fi

rm -f $OUTPUTCAP

exit 0
