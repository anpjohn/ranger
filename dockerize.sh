#!/bin/bash
#this script sets up the rangers
#
#################################################install docker, docker-compose, some other tools
#
#
apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common net-tools screen -y
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt install docker-ce -y
apt install docker-compose -y
wget -O /tmp/main.tar.gz https://github.com/anpjohn/ranger/archive/refs/heads/main.tar.gz
tar -xvf /tmp/main.tar.gz --directory /tmp/
#
#
###############################################libre
#
#
mkdir /var/lib/librenms
cd /var/lib/librenms
cp /tmp/ranger-main/librenms-env.txt /var/lib/librenms/.env
cp /tmp/ranger-main/librenms-librenms.env.txt /var/lib/librenms/librenms.env
cp /tmp/ranger-main/librenms-docker-compose.yml.txt /var/lib/librenms/docker-compose.yml
touch /var/lib/librenms/msmtpd.env
docker-compose -f /var/lib/librenms/docker-compose.yml up -d
#
#
##############################################openvas
#
#
mkdir /var/lib/openvas
cd /var/lib/openvas
mkdir /etc/default
rm -rf /etc/default/openvas-gsa
cp /tmp/ranger-main/openvas-gsa /etc/default/openvas-gsa
ip address
echo
echo
read -p "Enter the IP you want to access the web gui on in quotes, scroll up if you need it  :" ip_input
echo
echo
sednew=ALLOW_HEADER_HOST=$ip_input
sedoldip='"0.0.0.0"'
sedold=#ALLOW_HEADER_HOST=$sedoldip
sed -i "s/$sedold/$sednew/g" /etc/default/openvas-gsa
sed -i 's/#LISTEN_ADDRESS="0.0.0.0"/LISTEN_ADDRESS="0.0.0.0"/g' /etc/default/openvas-gsa
docker run -d -p 443:443 -v /etc/default/openvas-gsa:/etc/default/openvas-gsa -v /var/lib/openvas/data:/var/lib/openvas/mgr/ --name openvas --restart=always mikesplain/openvas
#
#
#####################################################ntopng
#
#
mkdir /var/lib/ntopng
cd /var/lib/ntopng
touch /var/lib/ntopng/ntopng.license
cp /tmp/ranger-main/ntopng-docker-compose-yml.txt /var/lib/ntopng/docker-compose.yml
ip address
echo
echo
read -p "enter the interface you want to use  :" interface_input
echo
echo
sedntopold=enp4s0
sedntopnew=$interface_input
sed -i "s/$sedntopold/$sedntopnew/g" /var/lib/ntopng/docker-compose.yml
docker-compose -f /var/lib/ntopng/docker-compose.yml up -d
#
#
#################################################oxidized
#
#
mkdir /var/lib/oxidized
cd /var/lib/oxidized
cp /tmp/ranger-main/oxidized-docker-compose.yml.txt /var/lib/oxidized/docker-compose.yml
mkdir /etc/oxidized/
cp /tmp/ranger-main/oxidized-etc-oxidized-config.txt /etc/oxidized/config
touch /etc/oxidized/router.db
docker-compose -f /var/lib/oxidized/docker-compose.yml up -d 
#
#
###############################################portainer
#
#
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
#
#
