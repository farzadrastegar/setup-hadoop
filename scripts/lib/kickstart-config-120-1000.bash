#!/bin/bash
# USAGE: ./kickstart-config.bash <server-ip> <network-device>

# get input arguments in order
server_ip=$1
network_device=$2
#rootpassword='$1$m94YPDA0$O4VvtW2eg0VIvff1pBKlG/' #prehduser2
rootpassword='$1$wnDltoQ5$5tGjJ4gOvRzsiKi7mxxO70' #123123

cat << EOF
#version=DEVEL

# Install OS instead of upgrade
install

url --url=ftp://${server_ip}/pub

# System language
lang en_US.UTF-8

# Keyboard layouts
# old format: 
keyboard us
# new format: keyboard --vckeymap=us --xlayouts='us'

# Network information
network  --onboot yes --device ${network_device} --bootproto dhcp --noipv6

# Root password
rootpw --iscrypted "${rootpassword}"

# Firewall configuration
firewall --disabled

# System authorization information
authconfig --enableshadow --passalgo=sha512

selinux --disabled

# System timezone
timezone --utc Asia/Tehran

# System bootloader configuration
bootloader --location=mbr --append="rhgb quiet"

# Partition clearing information
clearpart --all --initlabel

# Disk partitioning information
part /boot/efi --fstype vfat --size=200           --ondrive=sda
part /boot     --fstype ext3 --size=1024          --ondrive=sda
part /         --fstype ext3 --size=78233  --grow --ondrive=sda
part /var      --fstype ext3 --size=190771 --grow --ondrive=sdb
part /opt      --fstype ext3 --size=95334  --grow --ondrive=sdb
part /usr/hdp  --fstype ext3 --size=95334  --grow --ondrive=sdb
part /grid/1   --fstype ext3 --size=300000 --grow --ondrive=sdb
part /drid/2   --fstype ext3 --size=300000 --grow --ondrive=sdb


repo --name="pxe-repo" --baseurl=ftp://${server_ip}/pub --cost=100


%packages
@base
@core
@desktop-debugging
@dial-up
@directory-client
@fonts
@gnome-desktop
@guest-desktop-agents
@input-methods
@internet-browser
@java-platform
@multimedia
@network-file-system-client
@print-client
@x11
binutils
chrony
ftp
gcc
kernel-devel
kexec-tools
make
open-vm-tools
patch
python
%end


%post
/usr/bin/yum -y update >> /root/post_install.log 2>&1
/usr/bin/yum install epel-release >> /root/post_install.log 2>&1
/usr/bin/yum install pdsh >> /root/post_install.log 2>&1
/sbin/chkconfig --del bluetooth
/sbin/chkconfig --del cups
/sbin/chkconfig --del postfix

%end

EOF
exit 0
