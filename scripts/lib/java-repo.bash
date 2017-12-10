#!/bin/bash
# USAGE: ./java-repo.bash <pxe-server-ip> <jre rpm path> <jdk rpm path> <user@repo-server-ip>

# get input arguments in order
server_ip=$1
jre_rpm=$2
jdk_rpm=$3
repo_server=$4

java_repo="java1.8.repo"

cp ${jre_rpm} /var/ftp/pub/Packages
cp ${jdk_rpm} /var/ftp/pub/Packages


cat << EOF >> ${java_repo}
[java1.8-repo]
name=java1.8-repo
baseurl=ftp://${server_ip}/pub
enabled=1
gpgcheck=0
EOF

cmd="scp ${java_repo} ${repo_server}:/etc/yum.repos.d"

echo "Run the following command to complete:"
echo "${cmd}"

echo
echo "Repo waiting to transfer!"

exit 0
