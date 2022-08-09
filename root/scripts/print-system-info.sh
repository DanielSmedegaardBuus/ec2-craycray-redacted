#!/bin/bash
#
# Prints out all EC2 meta data for the current instance, sysstats, and whatnot.
# 
# Hehe :D Seems we actually have a bin for this locally - /usr/bin/ec2metadata

echo "EC2 META DATA"
echo "============="
echo "AMI ID                :" $(GET http://169.254.169.254/latest/meta-data/ami-id)
echo "AMI Launch Index      :" $(GET http://169.254.169.254/latest/meta-data/ami-launch-index)
echo "AMI Manifest Path     :" $(GET http://169.254.169.254/latest/meta-data/ami-manifest-path)
echo "Hostname              :" $(GET http://169.254.169.254/latest/meta-data/hostname)
echo "Instance Action       :" $(GET http://169.254.169.254/latest/meta-data/instance-action)
echo "Instance ID           :" $(GET http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance Type         :" $(GET http://169.254.169.254/latest/meta-data/instance-type)
echo "Metrics               :" $(GET http://169.254.169.254/latest/meta-data/metrics/)
echo "Local Hostname        :" $(GET http://169.254.169.254/latest/meta-data/local-hostname)
echo "Local IPv4            :" $(GET http://169.254.169.254/latest/meta-data/local-ipv4)
echo "MAC                   :" $(GET http://169.254.169.254/latest/meta-data/mac)
echo "Profile               :" $(GET http://169.254.169.254/latest/meta-data/profile)
echo "Placement             :" $(GET http://169.254.169.254/latest/meta-data/placement/)
echo "Public Hostname       :" $(GET http://169.254.169.254/latest/meta-data/public-hostname)
echo "Public IPv4           :" $(GET http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public Keys           :" $(GET http://169.254.169.254/latest/meta-data/public-keys/)
echo "Reservation ID        :" $(GET http://169.254.169.254/latest/meta-data/reservation-id)
echo "Security Groups       :" $(GET http://169.254.169.254/latest/meta-data/security-groups)
echo "Block Device Mapping  :"

for DEV in $(GET http://169.254.169.254/latest/meta-data/block-device-mapping/); do
    echo "                      : $DEV >" $(GET http://169.254.169.254/latest/meta-data/block-device-mapping/$DEV)
done

echo
echo
echo "PROCINFO"
echo "========"
procinfo