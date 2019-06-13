#!/bin/bash

# cd $KOLLA_ANSIBLE_GIT/

find . -type f -exec sed -i -r "s/\{\{ hostvars\[host\]\[\x27ansible_\x27 \+ hostvars\[host\]\[\x27api_interface\x27\]\]\[\x27ipv4\x27\]\[\x27address\x27\] \}\}/\[\{\{ hostvars\[host\]\[\x27ansible_\x27 \+ hostvars\[host\]\[\x27api_interface\x27\]\]\[\x27ipv6\x27\]\[0\]\[\x27address\x27\] \}\}\]/g" {} +

find . -type f -exec sed -i -r "s/\[\x27ipv4\x27\]/\[\x27ipv6\x27\]\[0\]/g" {} +

find . -type f -exec sed -i -r "s/net.ipv6/net.ipv6/g" {} +
find . -type f -exec sed -i -r "s///g" {} +
find . -type f -exec sed -i -r "s///g" {} +

find . -type f -exec sed -i -r "s/ahosts/ahosts/g" {} +
find . -type f -exec sed -i -r 's/\{\{ api_interface_address \}\}:/\[\{\{ api_interface_address \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ migration_interface_address \}\}\//\[\{\{{ migration_interface_address \}\}\]\//g' {} +

find . -type f -exec sed -i -r 's/memcached_servers = \{\% for host in groups\[\x27memcached\x27\] \%\}\[/memcached_servers = \{\% for host in groups\[\x27memcached\x27\] \%\}inet6\:\[/g' {} +
find . -type f -exec sed -i -r 's/memcache_servers = \{\% for host in groups\[\x27memcached\x27\] \%\}\[/memcache_servers = \{\% for host in groups\[\x27memcached\x27\] \%\}inet6\:\[/g' {} +

find . -type f -exec sed -i -r 's/\{\{ database_address \}\}:\{\{ database_port \}\}/\[\{\{ database_address \}\}\]:\{\{ database_port \}\}/g' {} +
find . -type f -exec sed -i -r 's/\{\{ monasca_database_address \}\}:/\[\{\{ monasca_database_address \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ elasticsearch_address \}\}:/\[\{\{ elasticsearch_address \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ redis_address \}\}:/\[\{\{ redis_address \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ keystone_database_address \}\}:/\[\{\{ keystone_database_address \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ keystone_service_ip \}\}:/\[\{\{ keystone_service_ip \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ xenserver_himn_ip \}\}:/\[\{\{ xenserver_himn_ip \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ host_ip \}\}:/\[\{\{ host_ip \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ host \}\}:/\[\{\{ host \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ syslog_server \}\}:/\[\{\{ syslog_server \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ nova_serialproxy_fqdn \}\}:/\[\{\{ nova_serialproxy_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ nova_spicehtml5proxy_fqdn \}\}:/\[\{\{ nova_spicehtml5proxy_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ nova_novncproxy_fqdn \}\}:/\[\{\{ nova_novncproxy_fqdn \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ kolla_internal_vip_address \}\}:/\[\{\{ kolla_internal_vip_address \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ kolla_external_vip_address \}\}:/\[\{\{ kolla_external_vip_address \}\}\]:/g' {} +

find . -type f -exec sed -i -r 's/\{\{ kolla_internal_fqdn \}\}:/\[\{\{ kolla_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ kolla_internal_fqdn_r1 \}\}:/\[\{\{ kolla_internal_fqdn_r1 \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ nova_internal_fqdn \}\}:/\[\{\{ nova_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ glance_internal_fqdn \}\}:/\[\{\{ glance_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ swift_internal_fqdn \}\}:/\[\{\{ swift_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ cinder_internal_fqdn \}\}:/\[\{\{ cinder_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ octavia_internal_fqdn \}\}:/\[\{\{ octavia_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ placement_internal_fqdn \}\}:/\[\{\{ placement_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ ironic_internal_fqdn \}\}:/\[\{\{ ironic_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ ironic_inspector_internal_fqdn \}\}:/\[\{\{ ironic_inspector_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ barbican_internal_fqdn \}\}:/\[\{\{ barbican_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ glance_internal_fqdn \}\}:/\[\{\{ glance_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ aodh_internal_fqdn \}\}:/\[\{\{ aodh_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ swift_internal_fqdn \}\}:/\[\{\{ swift_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ designate_internal_fqdn \}\}:/\[\{\{ designate_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ neutron_internal_fqdn \}\}:/\[\{\{ neutron_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ senlin_internal_fqdn \}\}:/\[\{\{ senlin_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ heat_cfn_internal_fqdn \}\}:/\[\{\{ heat_cfn_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ heat_internal_fqdn \}\}:/\[\{\{ heat_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ gnocchi_internal_fqdn \}\}:/\[\{\{ gnocchi_internal_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ keystone_internal_fqdn \}\}:/\[\{\{ keystone_internal_fqdn \}\}\]:/g' {} +

# External FQDNs
find . -type f -exec sed -i -r 's/\{\{ kolla_external_fqdn \}\}:/\[\{\{ kolla_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ nova_external_fqdn \}\}:/\[\{\{ nova_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ cinder_external_fqdn \}\}:/\[\{\{ cinder_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ octavia_external_fqdn \}\}:/\[\{\{ octavia_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ placement_external_fqdn \}\}:/\[\{\{ placement_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ ironic_external_fqdn \}\}:/\[\{\{ ironic_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ ironic_inspector_external_fqdn \}\}:/\[\{\{ ironic_inspector_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ barbican_external_fqdn \}\}:/\[\{\{ barbican_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ glance_external_fqdn \}\}:/\[\{\{ glance_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ aodh_external_fqdn \}\}:/\[\{\{ aodh_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ swift_external_fqdn \}\}:/\[\{\{ swift_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ designate_external_fqdn \}\}:/\[\{\{ designate_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ neutron_external_fqdn \}\}:/\[\{\{ neutron_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ senlin_external_fqdn \}\}:/\[\{\{ senlin_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ heat_cfn_external_fqdn \}\}:/\[\{\{ heat_cfn_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ heat_external_fqdn \}\}:/\[\{\{ heat_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ gnocchi_external_fqdn \}\}:/\[\{\{ gnocchi_external_fqdn \}\}\]:/g' {} +
find . -type f -exec sed -i -r 's/\{\{ keystone_external_fqdn \}\}:/\[\{\{ keystone_external_fqdn \}\}\]:/g' {} +
