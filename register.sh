#!/bin/bash 

# User vars
SAT6SERVER="sat6.example.net"
ORGID="EX"
DNS="192.168.1.1"

######################
red='\033[0;31m'
NC='\033[0m'
green='\033[0;32m'
mainversion=`cat /etc/redhat-release | awk -F'release' '{print $2}' | awk -F'.' '{print $1}' | sed 's/ //g'`

#### Here we go!
#Check activation key is set
if [ -z ${1+x} ] ; then
	echo "Please add activation key!" ; exit 1
else

rm -f /etc/yum.repos.d/*.repo
if [ $? -ne 0 ] ; then
        echo -e "${red}### removing yum repos ###${NC}"
else
        echo -e "${green}### removing yum repos ###${NC}"

fi

#Add tmp repo
echo "[kickstart]
name=kickstart
baseurl=http://$SAT6SERVER/pulp/repos/$ORGID/Library/content/dist/rhel/server/$mainversion/\$releasever/\$basearch/kickstart/
enabled=1
gpgcheck=0" > /etc/yum.repos.d/tmp.repo
echo -e "${green}### added tmp repo ###${NC}"

yum clean all > /dev/null 2>&1

#Remove any old config that will conflict with Satellite Server
#Remove katello-ca-consumer
yum remove katello-ca-consumer-$SAT6SERVER -y > /dev/null 2>&1
if [ $? -ne 0 ] ; then
        echo -e "${red}### katello-ca-consumer ###${NC}"
else
	echo -e "${green}### katello-ca-consumer ###${NC}"
	
fi

#Remove old puppet certs
rm -rf /var/lib/puppet/ssl/*
if [ $? -ne 0 ] ; then
        echo -e "${red}### puppet certs ###${NC}"
else
        echo -e "${green}### puppet certs ###${NC}"

fi

#Edit hosts / resolv.conf
if grep -q "nameserver $DNS" /etc/resolv.conf ; then
	echo -e "${green}### nameserver set ###${NC}" 
else
        echo -e "nameserver $DNS\n" >> /etc/resolv.conf
fi

#Install phyhon-hash-lib for RHEL5
if [ $mainversion -eq 5 ] ; then
        rpm -Uvh https://$SAT6SERVER/pub/python-hashlib-20081119-7.el5sat.x86_64.rpm > /dev/null 2>&1
fi

#install subscription-manager
yum install subscription-manager -y > /dev/null 2>&1
if [ $? -ne 0 ] ; then
        echo -e "${red}### Could not install subscription-manager ###${NC}" ; exit 2
else
        echo -e "${green}### subscription-manager installed ###${NC}"
fi

rm -f /etc/yum.repos.d/tmp.repo

#Install katello-ca-consumer
rpm -Uvh http://$SAT6SERVER/pub/katello-ca-consumer-latest.noarch.rpm > /dev/null 2>&1
if [ $? -ne 0 ] ; then
        echo -e "${red}### Could not install katello-ca-consumer ###${NC}" ; exit 3
else
        echo -e "${green}### katello-ca-consumer installed ###${NC}"

fi

#install product if not exist although it shoudl be there already 
if [ -d /etc/pki/product ] ; then
        cd /etc/pki/product/
        file=`ls -1 | grep pem$`
        if [[ $file ]] ; then
        echo -e "${green}### product already installed ###${NC}"
        elif [[ $mainversion -eq 5 ]] ; then
        curl http://$SAT6SERVER/pub/5Server.pem > 5Server.pem 2>/dev/null
	echo -e "${green}### product installed ###${NC}"
        elif [[ $mainversion -eq 6 ]] ; then
        curl http://$SAT6SERVER/pub/6Server.pem > 6Server.pem 2>/dev/null
	echo -e "${green}### product installed ###${NC}"
        elif [[ $mainversion -eq 7 ]] ; then
        curl http://$SAT6SERVER/pub/7Server.pem > 7Server.pem 2>/dev/null
	echo -e "${green}### product installed ###${NC}"
fi
fi

subscription-manager clean > /dev/null 2>&1
if [ $? -ne 0 ] ; then
        echo -e "${red}### subscription-manager clean ###${NC}" ; exit 4
else
        echo -e "${green}### subscription-manager clean ###${NC}"
fi

#Subscribe via subscription-manager
sub=`subscription-manager register --org="HO" --activationkey="$1"`
if [ $? -eq 0 ] ; then
	echo -e "${green}### Subscribed to $1 ###${NC}"
else
        echo -e "${red}### echo $sub ###${NC}" ; exit 5
fi

yum clean all

yum install puppet katello-agent -y
if [ $? -ne 0 ] ; then
        echo -e "${red}### Couldn't install puppet & katello-agent ###${NC}" ; exit 6
else
        echo -e "${green}### puppet & katello-agent installed ###${NC}"

fi

mv /etc/puppet/puppet.conf /etc/puppet/puppet.conf.default

echo "[main]
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = \$vardir/ssl

[agent]
    classfile = \$vardir/classes.txt
    pluginsync = true
    report = true
    ignoreschedules = true
    daemon = false
    ca_server = $SAT6SERVER
    server = $SAT6SERVER 
    localconfig = \$vardir/localconfig" > /etc/puppet/puppet.conf

chcon --reference=/etc/puppet/puppet.conf.default /etc/puppet/puppet.conf

puppet agent -t

#CleanUp

echo -e "${green}################\n### FINISHED ###\n################${NC}"
fi
