UbuntuPIAF
====================
Collection of scripts or whatever for use with Asterisk/PIAF/IncrediblePBX on Ubuntu 14.04 LTS.
Some scripts are just modified from Nerdvittles CentOS scripts, some is homebrew.  Will be adding more I have created later.
Forum thread: http://pbxinaflash.com/community/index.php?threads/wip-incrediblefax-for-ubuntu-incrediblepbx-install.15386/

*SHOULD-WORK* Status

Per WM's encouragement from the Ubuntu IncrediblePBX post on NV, I've been working on getting IncredibleFax to work on Ubuntu. I started from scratch but had issues, so for now I just hacked up the CentOS based scripts to be a little more "Ubuntufied".

I have not really been active on this forum or project so I don't know what development or repositories you guys use, so for now I just pushed it to my github.

There are 3 scripts available at this point. The primary AvantFAX installer rolls them all together. The other 2 are only needed if you had installed with this script prior to 08/25/2014.

REPO:
https://github.com/joshnorth/UbuntuPIAF

TESTED! (on KVM virtual machines):
Ubuntu 14.04 (i386) and Ubuntu 14.04.1 (amd64) default installs per the NV post on Ubuntu and IncrediblePBX at (http://nerdvittles.com/?p=9713).
Receiving faxes on multiple lines simultaneously (3 lines)
Fax to email
Fax categories and recipients in AvantFAX

Outbound FAX via WebGUI

NOT TESTED!
Email to fax (send)
Any custom destination or other advanced ways of receiving/sending
Print to fax with any HylaFAX/AvantFAX addons

INSTALLATION:
1. Install Ubuntu 14.04
2. Run through the IncrediblePBX (http://nerdvittles.com/?p=9713) install and reboot
3. Login as root via SSH and run the PIAF updater when asked - this fixes a reboot and MySQL glitch. *YOU MUST REBOOT HERE*
4. Install IncredibleFax, inserting your email address when requested. Press Enter for all other questions to accept the default options.
Code:
cd /root
wget --no-check-certificate https://raw.githubusercontent.com/joshnorth/UbuntuPIAF/master/incrediblefax11_ubuntu14.sh
chmod +x incrediblefax11_ubuntu14.sh
./incrediblefax11_ubuntu14.sh
reboot
*YOU MUST REBOOT HERE*

ISSUES:
1. Your default login should be admin/password. If you have problems with this, go to your root directory and run ./avantfax-pw-change
