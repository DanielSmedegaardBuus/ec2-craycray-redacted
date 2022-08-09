#!/bin/bash
#
# Snaps and backs up the local ring to S3 storage using cassandra-snapshotter.
# 
# THIS IS UNUSED ATM - cassandra-snapshotter doesn't seem to make good backups,
# and using btrfs without hourly fs level snapshots + daily backups to S3 is a
# much easier way to do a restore should we ever need to do so.
# 
# As all data is replicated across DCs, we don't really need to back all of them
# up. ATM we're just backing up the parser's database, as it's just a single
# node, and it's where the most changes occur, and most frequently.
# 
# You may pass along extra parameters to append to the cassandra-snapshotter
# command line (e.g. --new-snapshot to start over the backup from scratch).

. /root/scripts/shared.inc

# Assume all goes well:
ERRORS=false
OUTPUTCAP=/tmp/back-up-cassandra.out
rm -f $OUTPUTCAP

echo "Backing up local cassandra host(s) (${CASSANDRA_LAN_NODES// /, }) to S3 ..." | tee $OUTPUTCAP

# This one ought to work. That is, the --cassandra-data-path option should make
# the snapshotter work with the data files in custom locations so as ours.
# The only way it *does* work, however, is if we symlink /var/lib/cassandra ->
# /mnt/cassandra.
#cassandra-snapshotter --aws-access-key-id=$AWS_ACCESS_KEY_ID --aws-secret-access-key=$AWS_SECRET_ACCESS_KEY --s3-bucket-region=$AWS_DEFAULT_REGION --s3-bucket-name=myproject-cassandra --s3-ssenc --s3-base-path=${INSTANCE_NAME// /_} backup --hosts=${CASSANDRA_LAN_NODES// /,} --cassandra-data-path=/mnt/cassandra $1 $2 $3 $4 $5 $6 $7 $8 $9 | tee -a $OUTPUTCAP
cassandra-snapshotter --aws-access-key-id=$AWS_ACCESS_KEY_ID --aws-secret-access-key=$AWS_SECRET_ACCESS_KEY --s3-bucket-region=$AWS_DEFAULT_REGION --s3-bucket-name=myproject-cassandra --s3-ssenc --s3-base-path=${INSTANCE_NAME// /_} backup --hosts=${CASSANDRA_LAN_NODES// /,} $1 $2 $3 $4 $5 $6 $7 $8 $9 | tee -a $OUTPUTCAP

[[ "$?" = "0" ]] && rm -f $OUTPUTCAP && exit 0

shout "Failed to back up cassandra to S3" "Captured output: $NL2$(cat $OUTPUTCAP)"

rm -f $OUTPUTCAP

exit 1
