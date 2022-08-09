#!/bin/bash

echo "Installing s3cmd ..."

apt-get -y update && apt-get install -y s3cmd
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Installing fabric ..."

apt-get install -y fabric
[[ "$?" != "0" ]] && echo "Failed, aborting" && exit 1

echo "Done"

exit 0