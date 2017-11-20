#!/bin/bash
# USAGE: ./dhcp-config.bash <server-ip> <leftmost-ip-range> <rightmost-ip-range> <netmask>

# get input arguments in order
server_ip=$1
leftmost_ip_range=$2
rightmost_ip_range=$3
netmask=$4
subnet=$(echo ${server_ip} | awk -F'.' '{print $1"."$2"."$3".0"}')

cat << EOF
authoritative;
allow booting;
allow bootp;
default-lease-time 600;
max-lease-time 7200;

subnet ${subnet} netmask ${netmask} {
   range ${leftmost_ip_range} ${rightmost_ip_range};
   next-server ${server_ip};
   filename "pxelinux.0";
}
EOF
exit 0
