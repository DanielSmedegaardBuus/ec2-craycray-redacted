#!/bin/bash
#
# Reconfigures nginx loggin to do 7 daily logrotations, no more sending out
# emails, instead calling the log backup script.

echo "Configuring logrotate for nginx ..."

[[ ! -e /etc/logrotate.d/nginx ]] && echo "No nginx logrotate on this system" && exit 0

[[ "$(cat /etc/logrotate.d/nginx | grep 'back-up-rotated-logs')" != "" ]] && echo "Already patched" && exit 0

echo "Setting rotations to 7 ..."
sed -Ei 's:\srotate.+:\trotate 7:' /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Removing email shoutouts ..."
sed -Ei 's:\tmail ec2-logs@myproject.com::' /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Adding backup script executions ..."
sed -Ei 's:^(.+s /run/nginx.pid.+)$:\1\n\t\t/root/scripts/back-up-rotated-logs.sh:' /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Restarting rsyslog daemon ..."
service rsyslog restart
[[ "$?" != "0" ]] && echo "Failed" && exit 1

exit 0