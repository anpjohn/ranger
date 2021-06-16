#reconfigure images
#openvas
ip address
echo
echo
read -p "Enter the IP you want to access the web gui on in quotes for openvas, scroll up if you need it  : " ip_input
echo
echo
sednew=ALLOW_HEADER_HOST=$ip_input
sedoldip='"0.0.0.0"'
sedold=#ALLOW_HEADER_HOST=$sedoldip
sed -i "s/$sedold/$sednew/g" /etc/default/openvas-gsa
sed -i 's/#LISTEN_ADDRESS="0.0.0.0"/LISTEN_ADDRESS="0.0.0.0"/g' /etc/default/openvas-gsa
docker restart openvas
#ntopng
echo
echo
read -p "community edition? : y/n " community_input
if [ $community_input = n ] ; then
        sed -i s/--community//g /var/lib/ntopng/docker-compose.yml
fi
read -p "enter the interface you want to use  : " interface_input
echo
echo
sed -i "s/enp4s0/$interface_input/g" /var/lib/ntopng/docker-compose.yml
docker restart ntopng_ntopng_1; docker restart ntopng_redis_1
