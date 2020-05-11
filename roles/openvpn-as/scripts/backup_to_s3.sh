#!/bin/bash -x

# Run as sudoer

cd /usr/local/openvpn_as/
/bin/tar cfvz backup.tar.gz *.bak

/usr/local/bin/aws s3 cp backup.tar.gz s3://openvpnas/backup.tar.gz
