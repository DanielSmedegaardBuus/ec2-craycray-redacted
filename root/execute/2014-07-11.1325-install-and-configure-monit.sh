#!/bin/bash

echo "Installing monit ..."
apt-get install -y monit
[[ "$?" != "0" ]] && echo "Failed" && exit 1

echo "Configuring ..."
service myproject-configure-monit start
[[ "$?" != "0" ]] && echo "Failed" && exit 1

exit 0