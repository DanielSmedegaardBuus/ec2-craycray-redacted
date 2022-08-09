#!/bin/bash
#
# Reconfigures nginx loggin to do 7 daily logrotations, no more sending out
# emails, instead calling the log backup script.

echo "Installing cassandra-snapshotter prerequisites ..."

apt-get install -y python-dev python-pip lzop
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Installing cassandra-snapshotter ..."
pip install cassandra_snapshotter
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Success"

exit 0
