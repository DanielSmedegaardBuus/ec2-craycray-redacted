#!/bin/bash

echo "--- Wiping and recreating /srv ..."
rm -rf /srv && mkdir /srv && chown -R srv:srv /srv
[[ "$?" != "0" ]] && echo "Failed to wipe /srv" && exit 1

echo "--- Cloning a fresh copy of git@bitbucket.org:myproject/server.git into /srv ..."
git clone git@bitbucket.org:myproject/server.git /srv
[[ "$?" != "0" ]] && echo "Failed to clone git@bitbucket.org:myproject/server.git into /srv" && exit 2

echo "--- Restarting web socket workers ..."
/usr/bin/service myproject-ws-workers restart
[[ "$?" != "0" ]] && echo "Failed to restart web socket workers" && exit 2

exit 0
