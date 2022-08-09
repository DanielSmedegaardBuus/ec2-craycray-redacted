#!/bin/bash

echo "Restarting cron ..."

service cron restart
[[ "$?" != "0" ]] && echo "Failed" && exit 1

exit 0
