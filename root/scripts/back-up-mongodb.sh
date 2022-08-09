#!/bin/bash
#
# Backs up the the most recent snapshot of the local mongodb directory to S3
# storage ("myproject-cassandra" bucket in us-west-2).
# 
# As all data is replicated across DCs, we don't really need to back all of them
# up. ATM we're just backing up the parser's database, as it's just a single
# node, and it's where the most changes occur, and most frequently.
# 
# You may pass along extra parameters to append to the cassandra-snapshotter
# command line (e.g. --new-snapshot to start over the backup from scratch).

. /root/scripts/shared.inc

[[ "$RUNS_MONGO" != "true" ]] && echo "This instance does not run mongodb" && exit 0

# Capture script output to temporary file in case we fail and need to report:
OUTPUTCAP=/tmp/snapshot-mongodb-storage.out
echo "Backing up the most recent mongodb snapshot to S3 ..." | tee $OUTPUTCAP

do_fail()
{
    echo "Failed" | tee -a $OUTPUTCAP
    shout "Failure while backing up mongodb data files to S3" "Captured output: $NL2$(cat $OUTPUTCAP)"
    rm -f $OUTPUTCAP
    exit 1
}

SNAPSHOT=$(ls /mongodb/|grep snap|sort|tail -n 1)
[[ "$SNAPSHOT" = "" ]] && echo "Found no snapshots in /mongodb/" | tee -a $OUTPUTCAP && do_fail

echo "Piping $SNAPSHOT contents through tar through lz4 through s3cmd put ..." | tee -a $OUTPUTCAP
tar --create --atime-preserve --force-local --preserve-permissions --one-file-system --recursion -f - /mongodb/$SNAPSHOT | lz4c -9 | s3cmd --bucket-location=us-west-2 --reduced-redundancy put - s3://myproject-mongodb/${INSTANCE_NAME// /_}/$SNAPSHOT.tar.lz4 2>&1 | tee -a $OUTPUTCAP
[[ "$?" != "0" ]] && do_fail

echo "Done" | tee -a $OUTPUTCAP
rm -f $OUTPUTCAP
exit 0
