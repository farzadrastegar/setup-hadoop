#!/bin/bash
# USAGE: ./pxe-repo.bash <server-ip>

# get input arguments in order
server_ip=$1

cat << EOF
[pxe-repo]
name=pxe-repo
baseurl=ftp://${server_ip}/pub
enabled=1
gpgcheck=0
EOF
exit 0
