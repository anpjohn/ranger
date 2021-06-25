#!/bin/bash
#this script sets up the rangers
#
#################################################install docker, docker-compose, some other tools
#
#
apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common net-tools screen autossh python3 python3-pip git -y
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
read -p "Enter the IP you want to access the web gui on in quotes, scroll up if you need it (enter "0.0.0.0" if not onsite)  : " ip_input
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
read -p "community edition? : y/n " community_input
if [ $community_input = n ] ; then
        sed -i s/--community//g /var/lib/ntopng/docker-compose.yml
fi
read -p "enter the interface you want to use : " interface_input
echo
echo
sed -i "s/enp4s0/$interface_input/g" /var/lib/ntopng/docker-compose.yml
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
###############################################openvasreporttool
#
#
cd /var/lib/
git clone https://github.com/TheGroundZero/openvasreporting.git
cd /var/lib/openvasreporting
pip3 install -r requirements.txt
mv /tmp/ranger-main/parser.py /var/lib/openvasreporting/openvasreporting/libs
#
#
###############################################reversessh
#
#
chown root:root /tmp/ranger-main/sshd_config
chmod 644 /tmp/ranger-main/sshd_config
mv /tmp/ranger-main/sshd_config /etc/ssh
echo
echo
echo "Creating The Reversessh User"
echo
echo
useradd -s /bin/bash -m reversessh
su - reversessh -c "ssh-keygen -b 4096 -t rsa -N '' -f ~/.ssh/id_rsa"
cat /home/reversessh/.ssh/id_rsa.pub
#so this is partially broke, you need to login to reversessh user and run 
#autossh -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -R port1:localhost:22 -N -p 443 reversessh@reversessh.getanp.com
#then accept the rsa public key, there is a way to fix this but i havent had time
echo -n "Please put the above key on reversessh and create the user in mysql (enter to continue)"
read -p "Direct To SSH Port 22 (port1) enter port1 if configuring later:" ssh_port
read -p "Direct To 443 (OPENVAS) (port2): enter port2 if configuring later" openvas_port
read -p "Direct to 9000 (Portainer) (port3): enter port 3 if configuring later" portainer_port
read -p "Direct to 3000 (NTOPNG) (port4): enter port 4 if configuring later" ntopng_port
read -p "Direct to 8000 (LibreNMS) (port5): enter port 5 is configuring later" librenms_port
sed -i s/port1/${ssh_port}/g /tmp/ranger-main/rc.local 
sed -i s/port2/${openvas_port}/g /tmp/ranger-main/rc.local
sed -i s/port3/${portainer_port}/g /tmp/ranger-main/rc.local 
sed -i s/port4/${ntopng_port}/g /tmp/ranger-main/rc.local 
sed -i s/port5/${librenms_port}/g /tmp/ranger-main/rc.local 
cp /tmp/ranger-main/rc.local /etc/rc.local
chmod +x /etc/rc.local
echo "Installed, a reboot is recommended to make this go live"
su -m -c "autossh -f -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -R port1:localhost:22 -N -p 443 reversessh@reversessh.getanp.com" reversessh
su -m -c "autossh -f -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -R port2:localhost:443 -N -p 443 reversessh@reversessh.getanp.com" reversessh
su -m -c "autossh -f -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -R port3:localhost:9000 -N -p 443 reversessh@reversessh.getanp.com" reversessh
su -m -c "autossh -f -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -R port4:localhost:3000 -N -p 443 reversessh@reversessh.getanp.com" reversessh
su -m -c "autossh -f -M 0 -o 'ServerAliveInterval 30' -o 'ServerAliveCountMax 3' -R port5:localhost:8000 -N -p 443 reversessh@reversessh.getanp.com" reversessh
