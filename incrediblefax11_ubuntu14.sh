#!/bin/bash
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

# ver. 11.3 updates the script to support CentOS 6.5 et al and current locations
# gvtricks 5.5.2011
# updated HylaFax and AvantFax to latest releases
# updated to support CentOS 6.5 and Scientific Linux 6.5
# Ward Mundy & Associates LLC 04-03-2014
# customized for turnkey install with Incredible PBX 11
# Joe Roper 12.02.2009
# Based on a script written by Phone User
# http://pbxinaflash.com/forum/showthread.php?t=3093
# CHANGELOG 22nd September 2010
# Fixed misnaming of tgz file
# fixed installation directory
# removed test for Incredible
# Install Fax

# josh.north@point808.com
# 2014-08-04 - based on download from http://incrediblepbx.com/incrediblefax11.sh
# Modified and validated it installs (mostly) correctly on a fresh Ubuntu Server 14.04LTS 32 bit
# install with updates, reboot, and IncrediblePBX installed 
# from http://incrediblepbx.com/incrediblepbx11.4.ubuntu14
# Reboot and run as root and it *should* work, more or less
# TODO - fix or add comments, do some sort of error catching to fail gracefully when compilation
# breaks, fix sourceforge links (direct to a single mirror currently), fix prompts to specify 
# versions requirements etc, maybe convert inittab to upstart to be "Ubuntufied"
# ALSO TODO BEFORE RELEASE - Avantfax password setting not working right, and need link to Web UI in main
# NOTES/gotchas - this uses bash instead of sh.  must run as root (not plain sudo unless you sudo -i,
# and I have not tested that way thoroughly, even though it is more inline with Ubuntu practices)
# last, for now, have not tested 64-bit or the webmin module to see if it needs hacking

VERSION=`cat /etc/pbx/.version`
if [ -z "$VERSION" ]
then
 echo "Sorry. This installer requires Ubuntu PBX in a Flash and Incredible PBX 11.11."
fi
if [ "$VERSION" != "11.11" ]
then
 echo "Sorry. This installer requires Ubuntu PBX in a Flash and Incredible PBX 11.11."
fi

clear
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "This script installs Hylafax/Avantfax/IAXmodem on Ubuntu PIAF systems only!"
echo " "
echo "You first will need to enter the email address for delivery of incoming faxes." 
echo " "
echo "Thereafter, accept ALL the defaults except for entering your local area code. "
echo " "
echo "NEVER RUN THIS SCRIPT MORE THAN ONCE ON THE SAME SYSTEM!!!"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
read -p "Press any key to continue or ctrl-C to exit"

clear
echo -n "Enter EMAIL address for delivery of incoming faxes: "
read faxemail
echo "FAX EMail Address: $faxemail"
read -p "If this is correct, press any key to continue or ctrl-C to exit"
clear

#Change passw0rd below for your MySQL asteriskuser password if you have changed it from the default.
MYSQLASTERISKUSERPASSWORD=amp109

LOAD_LOC=/usr/src/

# Before we go any further lets fix the debian-sys-maint password problem with ubuntu incrediblepbx.  this bug prevents
# reboots and clean shutdowns without manual intervention
export ADMIN_PASS=passw0rd
DEBCONFPASSWORD=`awk '/^password/ { if (NR<7) print $3;}' /etc/mysql/debian.cnf`
mysql -u root -p${ADMIN_PASS} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '${DEBCONFPASSWORD}';"
mysql -u root -p${ADMIN_PASS} -e "flush privileges;"
sleep 5
killall mysqld
sleep 10
/etc/init.d/mysql start


#ok let's go
cd $LOAD_LOC

# upgrade first then install some dependencies
apt-get update && apt-get upgrade -y
apt-get install -y ghostscript gsfonts sharutils libtiff-tools mgetty mgetty-voice

#Install Hylafax first so that the directories are in place
mkdir /etc/hylafax
wget http://prdownloads.sourceforge.net/hylafax/hylafax-5.5.5.tar.gz
tar -zxvf hylafax*
cd hylafax*
./configure --nointeractive
make
make install
cp hfaxd/hfaxd.conf /etc/hylafax/
cp util/pagesizes /etc/hylafax/

#Install IAXMODEMS 0->3
apt-get install -y iaxmodem
touch /var/log/iaxmodem/iaxmodem.log
cd $LOAD_LOC
COUNT=0
while [ $COUNT -lt 4 ]; do
       echo "Number = $COUNT"
       touch /etc/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
	touch /var/log/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
       echo "
device /dev/ttyIAX$COUNT
owner uucp:uucp
mode 660
port 457$COUNT
refresh 300
server 127.0.0.1
peername iax-fax$COUNT
cidname Incredible PBX
cidnumber +0000000000$COUNT
codec ulaw
" > /etc/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT

#Setup IAX Registrations
echo "
[iax-fax$COUNT]
type=friend
host=127.0.0.1
port=457$COUNT
context=from-fax
requirecalltoken=no
disallow=all
allow=ulaw
jitterbuffer=no
qualify=yes
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
" >> /etc/asterisk/iax_custom.conf

#Setup Hylafax Modems
cp /usr/share/doc/iaxmodem/examples/config.ttyIAX /var/spool/hylafax/etc/config.ttyIAX$COUNT

echo "
t$COUNT:23:respawn:/usr/local/sbin/faxgetty ttyIAX$COUNT > /var/log/iaxmodem/iaxmodem.log
" >> /etc/inittab

COUNT=$((COUNT + 1))
done

chown -R uucp:uucp /etc/iaxmodem/
chown uucp:uucp /var/spool/hylafax/etc/config.ttyIAX*

#Configure Hylafax
touch /var/spool/hylafax/etc/FaxDispatch
echo "
case "$DEVICE" in
   ttyIAX0) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX0
   ttyIAX1) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX1
   ttyIAX2) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX2
   ttyIAX3) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX3
esac
" > /var/spool/hylafax/etc/FaxDispatch

chown uucp:uucp /var/spool/hylafax/etc/FaxDispatch

# Set up Dial Plan

echo "
[custom-fax-iaxmodem]
exten => s,1,Answer
exten => s,n,Wait(1)
exten => s,n,SendDTMF(1)
exten => s,n,Dial(IAX2/iax-fax0/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax1/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax2/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax3/\${EXTEN})
exten => s,n,Busy
exten => s,n,Hangup
" >> /etc/asterisk/extensions_custom.conf


RESULT=`/usr/bin/mysql -uasteriskuser -p$MYSQLASTERISKUSERPASSWORD <<SQL

use asterisk
INSERT INTO custom_destinations 
	(custom_dest, description, notes)
	VALUES ('custom-fax-iaxmodem,s,1', 'Fax (Hylafax)', '');
quit
SQL`

clear
echo "ATTN: We now are going to run the Hylafax setup script."
echo "Except for your default area code which must be specified,"
echo "you can safely accept every default by pressing Enter."
read -p "Press the Enter key to begin..."
clear

apt-get -y install php-mail-mime php-net-socket php-auth-sasl php-net-smtp php-mail php-mdb2 php-mdb2-driver-mysql gsfonts-x11 gsfonts-other fonts-freefont-ttf fonts-liberation xfonts-scalable fonts-freefont-otf t1-cyrillic cups-filters
mkdir /usr/local/lib/ghostscript
ln -s /usr/share/fonts/type1 /usr/local/lib/ghostscript/fonts

faxsetup

#Install Avantfax
cd $LOAD_LOC
wget http://downloads.sourceforge.net/project/avantfax/avantfax-3.3.3.tgz
tar zxfv $LOAD_LOC/avantfax*.tgz
cd avantfax-3.3.3
# Some sed commands to set the preferences
sed -i 's/ROOTMYSQLPWD=/ROOTMYSQLPWD=passw0rd/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/www-data/asterisk/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/fax.mydomain.com/pbx.local/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/INSTDIR=\/var\/www\/avantfax/INSTDIR=\/var\/www\/html\/avantfax/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/HYLADIR=\/usr/INSTDIR=\/usr\/local/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's|./debian-prefs.txt|/usr/src/avantfax-3.3.3/debian-prefs.txt|g'  $LOAD_LOC/avantfax-3.3.3/debian-install.sh
sed -i 's/apache2.2-common/apache2-data/g'  $LOAD_LOC/avantfax-3.3.3/debian-install.sh

##JN this is a really NASTY NASTY workaround but there is a known bug to fix https://bugs.launchpad.net/ubuntu/+source/php5/+bug/1310552
pear upgrade
gunzip /build/buildd/php5-5.5.9+dfsg/pear-build-download/*.tgz
pear upgrade /build/buildd/php5-5.5.9+dfsg/pear-build-download/*.tar

#also we need to link modem configs to hyla default dir
ln -s /var/spool/hylafax/etc/config.ttyIAX0 /etc/hylafax/
ln -s /var/spool/hylafax/etc/config.ttyIAX1 /etc/hylafax/
ln -s /var/spool/hylafax/etc/config.ttyIAX2 /etc/hylafax/
ln -s /var/spool/hylafax/etc/config.ttyIAX3 /etc/hylafax/

./debian-install.sh

service apache2 restart

asterisk -rx "module reload"

mysql -uroot -ppassw0rd avantfax <<EOF
use avantfax;
update UserAccount set username="admin" where uid=1;
update UserAccount set can_del=1 where uid=1;
update UserAccount set wasreset=1 where uid=1;
update UserAccount set acc_enabled=1 where uid=1;
update UserAccount set email="$faxemail" where uid=1;
update Modems set contact="$faxemail" where devid>0;
EOF

echo "
[from-fax]
exten => _x.,1,Dial(local/\${EXTEN}@from-internal)
exten => _x.,n,Hangup
" >> /etc/asterisk/extensions_custom.conf

sed -i 's|NVfaxdetect(5)|Goto(custom-fax-iaxmodem,s,1)|g' /etc/asterisk/extensions_custom.conf

asterisk -rx "dialplan reload"

cd $LOAD_LOC
wget http://incrediblepbx.com/hylafax_mod-1.8.2.wbm.gz

cd /usr/share/ghostscript/current/Resource/Init
mv Fontmap.GS Fontmap.GS.orig
wget http://incrediblepbx.com/Fontmap.GS

echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX0
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX0

echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX1
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX1

echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX2
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX2

echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX3
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX3

sed -i "s/a4/letter/" /var/www/html/avantfax/includes/local_config.php

sed -i "s/root@localhost/$faxemail/" /var/www/html/avantfax/includes/local_config.php
sed -i "s/root@localhost/$faxemail/" /var/www/html/avantfax/includes/config.php

chmod 1777 /tmp
chmod 555 /

# needed for WebMin module
perl -MCPAN -e 'install CGI'

sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX0' /etc/rc.local
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX1' /etc/rc.local
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX2' /etc/rc.local
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX3' /etc/rc.local

#use avantfax faxrcvd program instead of hylafax
mv /var/spool/hylafax/bin/faxrcvd /var/spool/hylafax/bin/faxrcvd_old
mv /var/spool/hylafax/bin/faxrcvd.php /var/spool/hylafax/bin/faxrcvd

# needed for /etc/cron.hourly/hylafax+
##JN is this the right place? what's this doing?
cd /etc/default
wget http://incrediblepbx.com/hylafax+
chmod 755 hylafax+

cd /root

clear
echo " "
echo " "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Incredible FAX with IAXModem/Hylafax/Avantfax installation complete"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " "
echo "Avantfax is password-protected. Log in as admin with your passwd-master PW using"
echo "a browser pointed to http://serverIPaddress/avantfax or use the PIAF Admin GUI."
echo " "
echo "Fax detection is NOT supported. Incoming fax support requires a dedicated DID! "
echo "See this post if you have trouble sending faxes: http://nerd.bz/10MecwG"
echo " "
echo "Point a DID at the Custom Destination FAX (Hylafax) which has been created for"
echo "you in FreePBX. Outbound faxing will go out via the normal trunks as configured."
echo "You may also route a fax DID to extension 329 (F-A-X) to receive inbound faxes."
echo " "
echo "A Hylafax webmin module has been placed in /usr/src/hylafax_mod-1.8.2.wbm.gz"
echo "This is added via Webmin | Webmin Configuration | Webmin Modules | From Local File"
echo " "
echo "For a complete tutorial and video demo, visit: http://nerdvittles.com/?p=738"
echo " "
echo "You must Reboot now to bring Incredible Fax online."
echo " "
read -p "Press any key to reboot or ctrl-C to exit"
reboot

