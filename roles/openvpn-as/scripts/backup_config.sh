#!/bin/bash -x

# Run as sudoer
# TODO Clean up this script

# Create backup
# From: https://openvpn.net/vpn-server-resources/configuration-database-management-and-backups/#Backing_up_the_OpenVPN_Access_Server_configuration

cd /usr/local/openvpn_as/etc/db
[ -e config.db ] &&../../bin/sqlite3 config.db .dump > ../../config.db.bak
[ -e certs.db ] &&../../bin/sqlite3 certs.db .dump > ../../certs.db.bak
[ -e userprop.db ] &&../../bin/sqlite3 userprop.db .dump > ../../userprop.db.bak
[ -e log.db ] &&../../bin/sqlite3 log.db .dump > ../../log.db.bak
[ -e config_local.db ] &&../../bin/sqlite3 config_local.db .dump > ../../config_local.db.bak
[ -e cluster.db ] &&../../bin/sqlite3 cluster.db .dump > ../../cluster.db.bak
[ -e clusterdb.db ] &&../../bin/sqlite3 clusterdb.db .dump > ../../clusterdb.db.bak
[ -e notification.db ] &&../../bin/sqlite3 notification.db .dump > ../../notification.db.bak 
cp ../as.conf ../../as.conf.bak
