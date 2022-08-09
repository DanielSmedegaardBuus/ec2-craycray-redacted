#!/bin/bash

echo "--- Chmodding /etc/init.d/myproject-ws-workers ..."
chmod +x /etc/init.d/myproject-ws-workers
[[ "$?" != "0" ]] && echo "Failed to make /etc/init.d/myproject-ws-workers executable" && exit 1

echo "--- Registering /etc/init.d/myproject-ws-workers with update-rc.d ..."
/usr/sbin/update-rc.d -f myproject-ws-workers remove
/usr/sbin/update-rc.d myproject-ws-workers defaults
[[ "$?" != "0" ]] && echo "Failed to register /etc/init.d/myproject-ws-workers with update-rc.d" && exit 2

exit 0
