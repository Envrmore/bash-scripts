#!/bin/bash

# Changes static network config to DHCP
echo "THIS SCRIPT IS NOT FINISHED YET!"
sleep 1
echo -e "Are you sure about this?\n Ctrl+C in 5 seconds to cancel!"
sleep 5
echo "Starting installation!"
sleep 1
echo "Making sure your internet is DHCP first..."
echo -e "auto lo\niface lo inet loopback\n\n# The Primary network interface\nauto enp0s3\niface enp0s3 inet dhcp" > /etc/network/interfaces
systemctl restart networking
export pid=$!
wait $pid
echo "Your updated IP Configuration :"
sleep 1 
ip a
sleep 3

# DNS Server
echo "Making sure your DNS is set to 8.8.8.8 first..."
sleep 1
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Repository update
echo "Updating repositories..."
sudo apt update > /dev/null 2>&1
export pid=$!
wait $pid
echo "Repositories has been updated."

# Sed install
sudo apt install sed -y > /dev/null 2>&1
sudo sed -i 's|iface enp0s3 inet dhcp/iface enp0s3 inet static\n\taddress 192.168.22.6/24\n\tgateway 192.168.22.254|' /etc/network/interfaces
sudo systemctl restart networking

# Static to dhcp[[:space:]]\+[0-9.] is looking for a sequence of one or more whitespace characters followed by digits and/or dots.
sudo sed -i '/iface enp0s3 inet static/ {
    s/iface enp0s3 inet static/iface enp0s3 inet dhcp/
    s/address[[:space:]]\+[0-9]\+/#address/
    s/netmask[[:space:]]\+[0-9]\+/#netmask/
    s/gateway[[:space:]]\+[0-9]\+/#gateway/
}' /etc/network/interfaces

# Necessary packages installation
echo "Installing necessary packages..."
sudo apt install apache2 libapache2-mod-php wget unzip curl bind9 bind9utils dnsutils -y > /dev/null 2>&1
export pid=$!  
wait $pid
echo "Packages installed."
sleep 2
echo "Will configure Apache2 in 5 seconds..."
sleep 5
echo "Configuring Apache2..."

# Apache2 for website configuration
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/smkdki.conf
sudo sed -i 's/ServerName www.example.com/ServerName www.smkdki6.net/' /etc/apache2/sites-available/smkdki.conf
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/smkdki/|' /etc/apache2/sites-available/smkdki.conf
sudo a2dissite 000-default.conf
export pid=$!
wait $pid
sudo a2ensite smkdki.conf
sleep 5
sudo systemctl restart apache2.service
sleep 3
sudo systemctl status apache2
sleep 3
echo "Will install and configure Bind9 in 5 seconds..."
sleep 3

# Bind9 configuration
echo "Installing Bind9 and related packages..."
sudo apt install bind9 bind9utils dnsutils -y > /dev/null 2>&1
export pid $!
wait $pid
echo "Packages installed. Configuring Bind9 in 5 seconds..."
sleep 5
sudo cp /etc/bind/db.local /etc/bind/db.smkdki
sudo cp /etc/bind/db.127 /etc/bind/db.192
sudo tail -n 20 /etc/bind/named.conf.default-zones >> /etc/bind/named.conf.local
sudo sed -i "s/file /"

# Postfix and Dovecot
echo "Installing Postfix, Dovecot, and related packages..."
sudo apt install postfix dovecot-imapd dovecot-pop3d -y > /dev/null 2>&1
export pid=$!
wait $pid
echo "Postfix and Dovecot related packages has been installed."
sleep 1
echo "Now configuring mail server..."
echo "home_mailbox = Maildir/" >>  /etc/postfix/main.cf
echo "message_size_limit = 20480000" >> /etc/postfix/main.cf
sudo systemctl restart postfix
