#!/bin/bash -x

# Run as sudoer
# TODO Clean up this script

host_name=$FQDN
if [[ -z ${host_name} ]]
then
  host_name="vpn.example.com"
fi

# Restore backup
# From: https://openvpn.net/vpn-server-resources/configuration-database-management-and-backups/#Recovering_a_server_with_SQlite3_dump_backup_files

service openvpnas stop
sleep 5s

cd /usr/local/openvpn_as/

rm ./etc/db/config.db ./etc/db/certs.db ./etc/db/userprop.db ./etc/db/log.db
rm ./etc/db/config_local.db ./etc/db/cluster.db ./etc/db/clusterdb.db
rm ./etc/db/notification.db ./etc/as.conf
[ -e config.db.bak ] && ./bin/sqlite3 < ./config.db.bak ./etc/db/config.db
[ -e certs.db.bak ] && ./bin/sqlite3 < ./certs.db.bak ./etc/db/certs.db
[ -e userprop.db.bak ] && ./bin/sqlite3 < ./userprop.db.bak ./etc/db/userprop.db
[ -e log.db.bak ] && ./bin/sqlite3 < ./log.db.bak ./etc/db/log.db
[ -e config_local.db.bak ] && ./bin/sqlite3 < ./config_local.db.bak ./etc/db/config_local.db
[ -e cluster.db.bak ] && ./bin/sqlite3 < ./cluster.db.bak ./etc/db/cluster.db
[ -e clusterdb.db.bak ] && ./bin/sqlite3 < ./clusterdb.db.bak ./etc/db/clusterdb.db
[ -e notification.db.bak ] && ./bin/sqlite3 < ./notification.db.bak ./etc/db/notification.db
[ -e as.conf.bak ] && cp ./as.conf.bak ./etc/as.conf

service openvpnas start
sleep 5s

cd /usr/local/openvpn_as/scripts

# Reset OpenVPN web services and daemons to defaults
# From: https://openvpn.net/vpn-server-resources/advanced-option-settings-on-the-command-line/#Reset_OpenVPN_web_services_and_daemons_to_defaults

./sacli --key "admin_ui.https.ip_address" --value "all" ConfigPut
./sacli --key "admin_ui.https.port" --value "943" ConfigPut
./sacli --key "cs.https.ip_address" --value "all" ConfigPut
./sacli --key "cs.https.port" --value "943" ConfigPut
./sacli --key "vpn.server.port_share.enable" --value "true" ConfigPut
./sacli --key "vpn.server.port_share.service" --value "admin+client" ConfigPut
./sacli --key "vpn.daemon.0.server.ip_address" --value "all" ConfigPut
./sacli --key "vpn.daemon.0.listen.ip_address" --value "all" ConfigPut
./sacli --key "vpn.server.daemon.udp.port" --value "1194" ConfigPut
./sacli --key "vpn.server.daemon.tcp.port" --value "443" ConfigPut

# Make openvpn user superuser
./sacli --user openvpn --key "prop_superuser" --value "true" UserPropPut

# Fix pre-2.7.5 config that prevents service start
# See: https://forums.openvpn.net/viewtopic.php?p=86620#p86620
sed -i -r -e 's/#boot_pam_users.0=openvpn/boot_pam_users.0=openvpn/' /usr/local/openvpn_as/etc/as.conf

# Set company name
sed -i -r -e 's/.*sa.company_name.*/sa.company_name=Auction Edge/' /usr/local/openvpn_as/etc/as.conf

# Set company logo idempotently
if [[ `grep -c logo /usr/local/openvpn_as/etc/as.conf` == "0" ]]
then
  sed -i -r -e 's/# The company name will be shown in the UI/# The company name will be shown in the UI\nsa.logo_image_file=\/usr\/local\/openvpn_as\/etc\/logo.png/' /usr/local/openvpn_as/etc/as.conf
fi

# Set FQDN
./sacli -k "host.name" --value "${host_name}" ConfigPut
