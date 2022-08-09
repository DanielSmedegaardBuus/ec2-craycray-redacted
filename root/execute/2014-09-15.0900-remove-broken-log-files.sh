#!/bin/bash
#
# Removes a bunch of broken .log.1 files that are left behind from a barfed 
# logrotate run.

rm -f /var/log/myproject*.1 /var/log/cassandra/system.log.1
exit $?