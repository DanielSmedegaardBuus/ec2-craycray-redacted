#!/bin/bash
#
# Remove old init.d references to myproject-ec2-storage, which no longer exists.

echo "Remove stale references to init.d script myproject-ec2-storage ..."

/usr/sbin/update-rc.d -f myproject-ec2-storage remove &&
    exit 0

echo "Failed"
exit 1
