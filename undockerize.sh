#!/bin/bash
#this script rips the rangers and all data so they can be repurposed 
#
#################################################rip docker, docker-compose, some other tools
#
#
apt purge docker-ce docker-compose -y
apt autoremove docker-ce docker-compose -y
#
#
#######librenms
rm -rf /var/lib/librenms
rm -rf /tmp/ranger-main
###openvas
rm -rf /var/lib/openvas
rm -rf /etc/default/openvas-gsa
##ntopng
rm -rf /var/lib/ntopng
##oxidized
rm -rf /var/lib/oxidized
rm -rf /etc/oxidized
##openvasreporttool
rm -rf /var/lib/openvasreporting
