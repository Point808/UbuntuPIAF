#!/bin/bash
# this fixes debconf apt postinst issues - udev and others as I find them
# NOTE - I know this is hackoriffic fix but it works.  Systemd is not terribly happy about it
# and you Ubuntu guys probably hate this but something is seriously broken and this (at least temporarily) fixes it.

# is udev broken? if so, fix it
if grep -q "invoke-rc.d udev restart" /var/lib/dpkg/info/udev.postinst; then
sed -i 's/invoke-rc.d udev restart/service udev restart/g' /var/lib/dpkg/info/udev.postinst
fi

echo "All done.  You should *probably* reboot your system now since we are messing with important system services."
read -p "Press any key to reboot or ctrl-C to exit"
reboot
