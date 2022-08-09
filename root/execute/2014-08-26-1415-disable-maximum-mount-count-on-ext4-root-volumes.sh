#!/bin/bash

echo "Disabling maximum mount count ext4 fsck thingamajig" &&
    /sbin/tune2fs -c 0 /dev/xvda1 &&
    echo "Done" &&
    exit 0

echo "Failed" &&
    exit 1
