#!/bin/bash
# this fixes debconf issues left after ubuntu incredible pbx install which breaks graceful shutdowns

export ADMIN_PASS=passw0rd
DEBCONFPASSWORD=`awk '/^password/ { if (NR<7) print $3;}' /etc/mysql/debian.cnf`
echo "Updating debian-sys-maint MySQL user password to match this system..."
mysql -u root -p${ADMIN_PASS} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '${DEBCONFPASSWORD}';"
echo "Flushing MySQL privileges..."
mysql -u root -p${ADMIN_PASS} -e "FLUSH PRIVILEGES;"
echo "Killing MySQL server the hard way..."
sleep 5
killall mysqld
echo "Let it rest for a second, and restart MySQL..."
sleep 10
/etc/init.d/mysql start
sleep 10
echo "All done.  You can reboot your system if you wish to verify, we should now be able to restart ok."
exit
