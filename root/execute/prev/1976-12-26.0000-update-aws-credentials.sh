#!/bin/bash
#
# Creates an awscli tools configuration file with the necessary credentials,
# using the region that the current instance is running in.

# Bail on any error
set -e

mkdir -p /root/.aws
echo "[default]" > /root/.aws/config
echo "aws_secret_access_key = REDACTED" >> /root/.aws/config
echo "aws_access_key_id = REDACTED" >> /root/.aws/config
echo "region =" $(ec2metadata | grep 'availability-zone:' | sed -E 's_availability-zone: __' | sed -E 's:.$::') >> /root/.aws/config
