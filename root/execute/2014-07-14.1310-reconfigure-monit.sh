#!/bin/bash

echo "Reconfiguring monit ..."
service myproject-configure-monit restart
[[ "$?" != "0" ]] && echo "Failed" && exit 1

exit 0