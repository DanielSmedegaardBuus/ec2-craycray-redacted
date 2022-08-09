#!/bin/bash
#
# Move srv:srv's $HOME to /home/srv (currently /srv), so that applications that
# need to store configuration data (like forever) can do so (/srv is owned by
# root).
# 

echo "Changing srv's home dir to /home/srv ..."

usermod -d /home/srv srv && mkdir -p /home/srv && chown srv:srv /home/srv &&
    exit 0

echo "Failed"
exit 1
