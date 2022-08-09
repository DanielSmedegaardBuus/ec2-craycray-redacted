#!/bin/bash

# Trap sighup, so we don't return before execute-once is killed when we reboot (or else we'd execute more scripts):
trap "" 1

# Bail on any error
set -e

# Store the current kernel version, so that we know if we need to purge an old kernel version after rebooting:
echo "$(uname -r|sed -E 's:-[a-z]+::')" > /root/kernel-version-before-reboot

# TODO: --force-confold on kernel updates ... hmmm ... could this cause grub to not update conf to use the new kernel?
apt-get -y update
apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade

reboot

# We don't want to return here, or more scripts will be executed before rebooting (TODO: Does this actually block?)
# TODO: Actually, we do - or we won't be tagged as having run! Probably better to add a sleep to the start of the 2nd
# boot script!
sleep 10m
