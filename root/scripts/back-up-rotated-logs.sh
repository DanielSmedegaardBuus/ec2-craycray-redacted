#!/bin/bash
#
# Moves selected rotated log files to S3.

. /root/scripts/shared.inc

# Target directory is instance name, lowercased and stripped of special chars:
TARGET_DIR=${INSTANCE_NAME,,}
TARGET_DIR=$(echo ${TARGET_DIR// /-} | sed -E 's:[^0-9a-z\-]::')

# Assume all goes well:
ERRORS=false
OUTPUTCAP=/tmp/back-up-rotated-logs.out
rm -f $OUTPUTCAP

# Do something and either tee the output if we're running in a TTY, or send output directly to the output cap
talk ()
{
    if [ -t 1 ]; then
        $@ 2>&1 | tee -a $OUTPUTCAP
        return ${PIPESTATUS[0]}
    fi
    $@ 2>&1 >> $OUTPUTCAP
    return $?
}

logfile_to_s3_name ()
{
    # Get the modified timestamp of the log file:
    TIMESTAMP=$(stat $1 | grep Modify | sed -E 's:Modify..::' | sed -E 's:\..+::')
    # Format as YYYY-MM-DD-HH.mm.SS':
    TIMESTAMP=${TIMESTAMP//:/.}
    TIMESTAMP=${TIMESTAMP// /-}
    # Strip /var/log from the path:
    S3_NAME=${1//\/var\/log\//}
    # Turn log-file-name.1.gz into log-file-name/DATE.gz
    S3_NAME=$(echo $S3_NAME | sed -E 's:^(.+)\.[0-9]+\.gz:\1/___TIMESTAMP___.gz:')
    S3_NAME=${S3_NAME/___TIMESTAMP___/$TIMESTAMP}
    
    echo $S3_NAME
}

talk echo "Backing up log files ..."

for LOG in $(ls /var/log/myproject*.gz /var/log/cassandra/*.gz /var/log/nginx/*.gz /var/log/syslog*.gz /var/log/auth*.gz 2>/dev/null); do
    
    TARGET_FILE=$(logfile_to_s3_name $LOG)
    
    talk s3cmd --bucket-location=EU --reduced-redundancy put $LOG s3://myproject-logs/$TARGET_DIR/$TARGET_FILE
    
    if [[ "$?" = "0" ]]; then
        rm -f $LOG
    else
        ERRORS=true
    fi
done

[[ $ERRORS = false ]] && rm -f $OUTPUTCAP && exit 0

shout "Failed to back up rotated logs to S3" "Captured output: $NL2$(cat $OUTPUTCAP)"

rm -f $OUTPUTCAP

exit 1
