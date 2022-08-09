#!/bin/bash
#
# Download and install the latest version of s3cmd (1.6.0, which supports
# uploads via stdin, and should be safer than the current Ubuntu provided one,
# 1.1.0-beta3)

cd /tmp

echo "Downloading s3cmd tarball ..."

wget http://downloads.sourceforge.net/project/s3tools/s3cmd/1.6.0/s3cmd-1.6.0.tar.gz
[[ "$?" != "0" ]] && echo "Failed" && exit 1

echo "Extracting ..."
tar xvf s3cmd-1.6.0.tar.gz
[[ "$?" != "0" ]] && echo "Failed" && exit 1

echo "Installing ..."
cd s3cmd-1.6.0 && python setup.py install
[[ "$?" != "0" ]] && echo "Failed" && exit 1

echo "Purging Ubuntu-provided s3cmd ..."
apt-get purge -y s3cmd
[[ "$?" != "0" && "$?" != "100" ]] && echo "Failed" && exit 1

echo "Installing dependencies for tarball version ..."
apt-get update && apt-get install -y python-dateutil
[[ "$?" != "0" ]] && echo "Failed" && exit 1

echo "Cleaning up ..."
cd .. && rm -rf s3cmd-1.6.0* && apt-get clean
[[ "$?" != "0" ]] && echo "Failed" && exit 1

echo "All done."
exit 0
