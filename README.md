UbuntuPIAF
====================
Collection of scripts or whatever for use with Asterisk/PIAF/IncrediblePBX on Ubuntu 14.04 LTS.
Some scripts are just modified from Nerdvittles CentOS scripts, some is homebrew.  Will be adding more I have created later.

1.  incrediblefax11_ubuntu14.sh - this is to install IncredibleFax on a fresh Ubuntu 14.04 system that has just had the IncrediblePBX script run on it.
  NOTES: First run through incrediblepbx installer as root.  Reboot.  Then run script 2 below (Fix MySQL).  Then download and run this script as root user.  You will be asked to insert your email address first.  Watch for the prompt to set up area code and enter it correctly!  You get one shot.  EVERYTHING ELSE just hit enter for the default!!!
2.  FixIncrediblePBXMySQL.sh - this corrects the debian-sys-maint MySQL password problem that is somehow inherited from the Ubuntu IncrediblePBX install script.  I have not had time to debug that script, it was easier for the time being to just write this to fix it.
3.  TODO
