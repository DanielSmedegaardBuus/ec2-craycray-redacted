#!/bin/bash

echo "Installing python-magic (for s3cmd) ..."

apt-get install -y python-magic
[[ "$?" != "0" ]] && echo "Failed" && exit 1

exit 0