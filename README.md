UbuntuPIAF
====================
Collection of scripts or whatever for use with Asterisk/PIAF/IncrediblePBX on Ubuntu 14.04 LTS.
Some scripts are just modified from Nerdvittles CentOS scripts, some is homebrew.  Will be adding more I have created later.
Forum thread: http://pbxinaflash.com/community/index.php?threads/wip-incrediblefax-for-ubuntu-incrediblepbx-install.15386/

1.  incrediblefax11_ubuntu14.sh - this is to install IncredibleFax on a fresh Ubuntu 14.04 system that has just had the IncrediblePBX script run on it.
  NOTES: First run through incrediblepbx installer as root.  Reboot.  Then run script 2 below (Fix MySQL).  Then download and run this script as root user.  You will be asked to insert your email address first.  Watch for the prompt to set up area code and enter it correctly!  You get one shot.  EVERYTHING ELSE just hit enter for the default!!!
2.  FixIncrediblePBXMySQL.sh - this corrects the debian-sys-maint MySQL password problem that is somehow inherited from the Ubuntu IncrediblePBX install script.  I have not had time to debug that script, it was easier for the time being to just write this to fix it.

TESTED! (on KVM virtual machines):
Ubuntu 14.04 (i386) and Ubuntu 14.04.1 (amd64) default installs per the NV post on Ubuntu and IncrediblePBX at (http://nerdvittles.com/?p=9713).
Receiving faxes on multiple lines simultaneously (3 lines)
Fax to email
Fax categories and recipients in AvantFAX

NOT TESTED!
Email to fax (send)
Any fax sending
Any custom destination or other advanced ways of receiving/sending
Print to fax with any HylaFAX/AvantFAX addons

