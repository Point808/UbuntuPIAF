# UbuntuPIAF #
### About: ###
Josh North - josh.north@point808.com  
Collection of scripts for use with Asterisk/PIAF/IncrediblePBX on Ubuntu 14.04 LTS.  Some scripts are just modified Nerdvittles CentOS scripts, some are homebrew.  Will be adding more I have created later.  
Forum thread: http://pbxinaflash.com/community/index.php?threads/wip-incrediblefax-for-ubuntu-incrediblepbx-install.15386/  

### Working: ###
Ubuntu 14.04 (i386) and Ubuntu 14.04.1 (amd64) default installs per the NV post on Ubuntu and IncrediblePBX at (http://nerdvittles.com/?p=9713).  
Receiving faxes on multiple lines simultaneously (3 lines)  
Fax to email  
Fax categories and recipients in AvantFAX  
Outbound FAX via WebGUI  

### Untested: ###
Email to fax (send)  
Any custom destination or other advanced ways of receiving/sending  
Print to fax with any HylaFAX/AvantFAX addons  

### Installation: ###
1. Install Ubuntu 14.04  
2. Run through the IncrediblePBX (http://nerdvittles.com/?p=9713) install and reboot  
3. Login as root via SSH and run the PIAF updater when asked - this fixes a reboot and MySQL glitch. *YOU MUST REBOOT HERE*  
4. Install IncredibleFax, inserting your email address when requested. Press Enter for all other questions to accept the default options.  
```
cd /root  
wget --no-check-certificate https://git.point808.com/Point808/UbuntuPIAF/raw/master/incrediblefax11_ubuntu14.sh  
chmod +x incrediblefax11_ubuntu14.sh  
./incrediblefax11_ubuntu14.sh  
reboot  
```

*YOU MUST REBOOT HERE*

### Issues: ###
1. Your default login should be admin/password. If you have problems with this, go to your root directory and run the following:  
```
./avantfax-pw-change
```


