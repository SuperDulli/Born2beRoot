#!/bin/bash
wall $'#Architecture: ' `uname -a` \
$'\n#CPU physical: '`grep 'cpu cores' /proc/cpuinfo | cut -d ':' -f 2` \
$'\n#vCPU: '`grep 'processor' /proc/cpuinfo | wc -l` \
$'\n#Memory Usage: '`free -m | grep 'Mem' | awk '{ printf "%s/%sMB (%.2f%%)", $3,$2,($3/$2)*100 }'` \
$'\n#Disk Usage: '`df -h | awk '$NF=="/"{ printf "%.2f/%.2fGB (%s)",$3,$2,$5 }'` \
$'\n#CPU load: '`uptime | awk '{ printf "%.1f%%",$(NF-2)*100 }'` \
$'\n#Last boot: '`who --boot | awk '{ printf "%s %s",$(NF-1),$NF }'` \
$'\n#LVM use: '`lsblk | grep lvm | awk '{ if ($1) { print "yes";exit; } else { print "no" } }'` \
$'\n#Connections TCP: '`netstat --numeric --all --tcp | grep ESTABLISHED | wc -l` \
$'\n#User log: '`users | wc -w` \
$'\n#Network: IP '`hostname --all-ip-address`"("`ip address | grep link/ether | awk '{ print $2 }'`")" \
$'\n#Sudo: '`grep -c COMMAND /var/log/sudo/sudo.log` "CMD"
