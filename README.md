# sat6
Scripts / puppet modules that I have used with Red Hat Satellite Server 6 (Katello)

register.sh
-----------
Script created to register RHEL clients to Satellite Server. It requires:
  - [1] You have sync'd the kickstart repos. 
  - [2] Placed python-hashlib-20081119-7.el5sat.x86_64.rpm in /var/www/html/pub/ on Satellite Server. (if you want to use a different version change line 66)
  - [3] Placed .pem files named 5Server.pem, 5Server.pem, 7Server.pem etc... for all majour RHEL version in /var/www/html/pub/ on Satellite Server. 

Puppet Modules
===============
puppet
-----------
Manages puppet.conf and add a cronjob to run puppet every 30 mins. Also have a fact to tell which site a server is running from based on its IP address it gets from Satellite Server (this requires a ip.php file in /var/www/html/pub/ on your Satellite server(see requirements folder) you will also need to install php on Satellite Server).

hardening
-----------
Applys various settings for harderning a RedHat based Linux system. This module was created by extensively borrowing from Graham Hares [sat6-cis-level1-rhel6-puppet-module](https://github.com/grahamrht/sat6-cis-level1-rhel6-puppet-module).
