#!/bin/sh
###################################################################
## get_info.sh
## Author: Simon Smith
## Decription: Gathers system information into a single file output
## Usage: Should be executed as a root privileged user for maximum benefit
####################################################################
echo '***********uname -a******************' > system_info.txt
uname -a >> system_info.txt
echo '************redhat-release*****************' >> system_info.txt
cat /etc/redhat-release >> system_info.txt
echo '************version*****************' >> system_info.txt
cat /proc/version >> system_info.txt
echo '************df*****************' >> system_info.txt
df -lh >> system_info.txt
echo '************mounts*****************' >> system_info.txt
cat /proc/mounts >> system_info.txt
echo '************cpuinfo*****************' >> system_info.txt
cat /proc/cpuinfo >> system_info.txt
echo '************meminfo*****************' >> system_info.txt
cat /proc/meminfo >> system_info.txt
echo '************free*****************' >> system_info.txt
free >> system_info.txt
echo '************ifconfig*****************' >> system_info.txt
ifconfig >> system_info.txt
netstat –nr >> system_info.txt
cat /etc/resolv.conf >> system_info.txt
echo '************cmdline*****************' >> system_info.txt
cat /proc/cmdline >> system_info.txt
echo '************pmon*****************' >> system_info.txt
ps -ef | grep pmon >> system_info.txt
echo '************ORACLE*****************' >> system_info.txt
env | grep ORACLE >> system_info.txt
echo '************ORACLE crontab*****************' >> system_info.txt
crontab -u oracle -l >> system_info.txt
echo '************root crontab*****************' >> system_info.txt
crontab -l >> system_info.txt
echo '************passwd*****************' >> system_info.txt
cat /etc/passwd >> system_info.txt
echo '************groups*****************' >> system_info.txt
cat /etc/group >> system_info.txt
echo '*************samba****************' >> system_info.txt
cat /etc/samba/smb.conf >> system_info.txt
echo '************END_OF_REPORT*****************' >> system_info.txt
echo 'Report complete, see results file system_info.txt'
exit
