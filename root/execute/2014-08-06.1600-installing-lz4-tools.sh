#!/bin/bash

echo "Installing lz4 tools ..."

apt-get -y update && apt-get -y install liblz4-tool
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Done"

exit 0