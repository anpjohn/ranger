#!/bin/bash
apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt install docker-ce -y
apt install docker-compose -y
wget -O /tmp/main.tar.gz https://github.com/anpjohn/ranger/archive/refs/heads/main.tar.gz
tar -xvf /tmp/main.tar.gz
#portainer
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
#libre
mkdir /var/lib/librenms
mv /tmp/ranger-main/librenms-env.txt /var/lib/librenms/.env
mv /tmp/ranger-main/librenms-docker-compose.yml.txt /var/lib/librenms/docker-compose.yml
touch msmtpd.env
docker-compose up -d
#openvas
#mkdir /var/lib/openvas
#docker run -d -p 443:443 -v /var/lib/openvas/data:/var/lib/openvas/mgr/ --name openvas --restart=always mikesplain/openvas
#docker exec -it openvas /bin/bash
#
#apt update -y
#apt install nano
#
#ntopng
mkdir /var/lib/ntopng
touch /var/lib/ntopng/ntopng.license
mv /tmp/ranger-main/ntopng-docker-compose-yml.txt /var/lib/ntopng/docker-compose.yml
docker-compose up -d
#oxidized
mkdir /var/lib/oxidized
mv /tmp/ranger-main/oxidized-docker-compose.yml.txt /var/lib/oxidized/docker-compose.yml
mkdir /etc/oxidized/
mv /tmp/ranger-main/oxidized-etc-oxidized-config.txt /etc/oxidized/config
touch /etc/oxidized/router.db
docker-compose up -d


