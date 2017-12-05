#!/bin/bash
USAGE="USAGE: ./mypdsh.bash <usernames> <machines IPs> <bash script filename in current dir>"
echo "${USAGE}"
read -p "Press any key to continue..." anykey

# Assumptions
# 1) The remote machine has the .ssh directory already set up
# 2) Run 'pre0-after-linux-installation.bash' before running this script

# input arguments
users=$1
ips=$2
script2run=$3

# Variables
host_dir="host-config"
ssh_password='123123'

i=0
for host in `paste -d'@' ${users} ${ips} 2>/dev/null`; do 
   userATip[$i]=${host}
   ((i++))

   echo "Recognizing ${host}..."

   #make sure .ssh exists
   ssh_cmd="sshpass -p ${ssh_password} ssh ${host} \"mkdir -p ${host_dir}\""
   eval "${ssh_cmd}"

   #copy the script into the remote machine and run it
   eval sshpass -p ${ssh_password} scp "${script2run}" "${host}:~/${host_dir}"
   ssh_cmd="sshpass -p ${ssh_password} ssh ${host} \"cd ${host_dir}; bash ./${script2run}\""
   eval "${ssh_cmd}"
done

