#!/bin/bash
#
# Sets up logrotate to do daily logrotations, just 3 of them, and to mail out
# purged log files.

echo "Configuring logrotate for nginx ..."

[[ ! -e /etc/logrotate.d/nginx ]] && echo "No nginx logrotate on this system" && exit 0

[[ "$(cat /etc/logrotate.d/nginx | grep 'myproject.com')" != "" ]] && echo "Already patched" && exit 0

echo "Switching to daily rotations ..."
sed -Ei 's:\sweekly:\tdaily:' /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Setting rotations to 5 ..."
sed -Ei 's:\srotate.+:\trotate 5:' /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Configuring for mailouts ..."
sed -Ei 's:}:\tmail ec2-logs@myproject.com:' /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Closing file ..."
echo '}' >> /etc/logrotate.d/nginx
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Restarting rsyslog daemon ..."
service rsyslog restart
[[ "$?" != "0" ]] && echo "Failed" && exit 1

exit 0