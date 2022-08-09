#!/bin/bash
#
# Put a hold on java and cassandra, and upgrade the rest.
#

export DEBIAN_FRONTEND=noninteractive
apt-get update
echo "cassandra hold" | dpkg --set-selections
echo "java-common hold" | dpkg --set-selections
echo "oracle-java7-installer hold" | dpkg --set-selections
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
apt-get clean
