#!/bin/bash

# Bail on any error
set -e

[[ ! -e /root/kernel-version-before-reboot ]] && echo "No kernel version from first boot found!" && exit 1

CUR_KERNEL=$(uname -r|sed -E 's:-[a-z]+::')
PREV_KERNEL=$(cat /root/kernel-version-before-reboot)

if [[ "$PREV_KERNEL" != "$CUR_KERNEL" ]]; then
    apt-get purge linux-headers-$PREV_KERNEL linux-headers-$PREV_KERNEL-generic linux-image-$PREV_KERNEL-generic
fi

apt-get clean

rm /root/kernel-version-before-reboot

echo "Running kernel $CUR_KERNEL (AMI kernel $PREV_KERNEL), about to do auto-configuration. Instance info: $(echo ''; echo ''; print-system-info.sh)" | mail -s "New instance launched" -t $EMAIL_RECIPIENT