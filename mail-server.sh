#!/bin/bash

# Checks whether the user is root or not
if (( "$EUID" != 0 )); then
    echo "You are not root. Please run as root, now exiting."
    exit
fi

# Changes static network config to DHCP
echo -e "THIS SCRIPT IS NOT FINISHED YET!\nThis script will install Postfix, Dovecot, Apache2, MariaDB, Roundcube"; sleep 1
echo -e "Before installing, please make sure that this host's network is DHCP and is able to reach the internet\n/
because there are some packages that is necessary to be installed beforehand. Ctrl+C to cancel in 5 seconds..."; sleep 5
echo "Starting installation!"; sleep 1

# DNS Server
## echo "Making sure your DNS is set to 8.8.8.8 first..."; sleep 1
## echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Repository update
echo "Updating repositories..."
sudo apt update > /dev/null 2>&1; export pid=$!; wait $pid
echo "Repositories has been updated. Now checking sed..."

sedCheck() {
    if ! hash sed 2> /dev/null; then
        echo "The command 'sed' is not installed, will install now."
        apt install sed -y
    else
        exit 1
    fi    
}

# Network Configuration
while true; do
    echo "Network configuration, please use lowercase on all."; sleep 1
    read -rp "Do you use NetworkManager as your main network manager? [yes/no] : " NMEXIST
    case "$NMEXIST" in
        [y][e][s])
        break;;

        [n][o])
        read -rp "Network configuration method, static or dhcp? [dhcp]: " NWMETHOD
        NWMETHOD=${NWMETHOD:-dhcp}

        case "$NWMETHOD" in
            [s][t][a][t][i][c])
            while true; do
                read -rp "Which interface should be configured(e.g enp0s3, eth0)[enp0s3]: " HOSTINT
                HOSTINT=${HOSTINT:-enp0s3}

                while true; do
                    read -rp "Configure your IP address [192.168.0.2] : " HOSTIP
                    HOSTIP=${HOSTIP:-192.168.0.2}
                    if [[ $HOSTIP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                        break
                    else
                        echo "Invalid host IP address format. Please try again."
                    fi
                done

                while true; do
                    read -rp "Configure your netmask [255.255.255.0] : " HOSTNETMASK
                    HOSTNETMASK=${HOSTNETMASK:-255.255.255.0}
                    if [[ $HOSTNETMASK =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                        break
                    else
                        echo "Invalid network mask format. Please try again."
                    fi
                done

                while true; do                
                read -rp "Configure your gateway [192.168.0.1] : " HOSTGW
                HOSTGW=${HOSTGW:-192.168.0.1}
                    if [[ $HOSTGW =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                        break
                    else
                        echo "Invalid gateway IP address format. Please try again."
                    fi
                done
                   
                while true; do
                read -rp "Configure which DNS nameserver(s) to use [192.168.0.1] : " HOSTDNS
                HOSTDNS=${HOSTDNS:-192.168.0.1}
                    if [[ $HOSTDNS =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
                        break
                    else
                        echo "Invalid DNS name server address format. Please try again."
                    fi
                done




                while true; do
                    echo "### Review your configuration"
                    while true; do
                        echo -e "Your IP configuration as follows :\nInterface\t: $HOSTINT\nIP address\t: $HOSTIP\nNetmask\t\t: $HOSTNETMASK\nGateway\t\t: $HOSTGW\nDNS server\t: $HOSTDNS"
                    read -rp "Is this correct?[yes/no] : " USERDECISION

                    case "$USERDECISION" in
                        [yY][eE][sS])
                        sedCheck()
                        echo "Network will be set as the configuration above"
                        sed -i "s|allow-hotplug $HOSTINT|auto $HOSTINT|" ./test.txt
                        sed -i "s|iface $HOSTINT inet dhcp|iface $HOSTINT inet static\n\taddress $HOSTIP\n\tnetmask $HOSTNETMASK\n\tgateway $HOSTGW\n\tdns-nameservers $HOSTDNS|" ./test.txt
                        break 4;;

                        [nN][oO])
                        echo "Restarting configuration..."
                        break 2;;

                        *)
                        echo "Please choose 'yes' or 'no'"
                        break;;
                    esac
                    done

                done
                break
            done;;

            [d][h][c][p])
            echo "You chose DHCP. Now sending DHCPREQUEST..."; sleep 5
            ## cp /etc/network/interfaces /etc/network/interfaces.bak; echo -e "\n\n\nThis file is the backup for the original file"
            ## DHCP request command
            export pid=$!; wait $pid
            echo "DHCP request succesfully done"
            break;;
        esac
    esac
done

echo "Succesfully changed the network configuration!"

systemctl restart networking
export pid=$!; wait $pid

# Sed install
sudo apt install sed -y > /dev/null 2>&1
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
sudo apt install apache2 libapache2-mod-php wget unzip curl -y > /dev/null 2>&1
export pid=$!; wait $pid
echo "Packages have been installed, will configure Apache2 in 3 seconds..."; sleep 3

# Apache2 for website configuration
read -p "What domain name would you like to use?(use FQDN)[www.example.org]" domainname
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/website.conf
sudo sed -i 's/ServerName www.example.com/ServerName $domainname/' /etc/apache2/sites-available/website.conf
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/website/|' /etc/apache2/sites-available/website.conf
sudo a2ensite $.conf && sudo a2dissite 000-default.conf 
sudo systemctl restart apache2.service && sudo systemctl status apache2
echo "Will install and configure Bind9 in 3 seconds..."
sleep 3

# Bind9 configuration
sudo apt install bind9 bind9utils dnsutils -y > /dev/null 2>&1
export pid $!; wait $pid
echo "Packages installed. Configuring Bind9 in 3 seconds..."; sleep 3

read -p "Please input the name that should be used for naming the db :" dbname
read -p "Please input your network IP ([192].168.0.0) :" ip
sudo cp /etc/bind/db.local /etc/bind/db.$dbname && sudo cp /etc/bind/db.127 /etc/bind/db.$ip
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
