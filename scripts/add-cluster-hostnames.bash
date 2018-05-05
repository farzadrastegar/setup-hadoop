#!/bin/bash
USAGE="USAGE: ./add-cluster-hostnames.bash <usernames> <machines IPs> <machines hostnames>"
echo "${USAGE}"
read -p "Press any key to continue..." anykey

# Assumptions
# 1) The remote machine has the .ssh directory already set up
# 2) Run 'pre0-after-linux-installation.bash' before running this script

# input arguments
users=$1
ips=$2
hostnames=$3
script2run="add-node-hostname.bash"

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

   hostname=`cat ${hostnames} | sed "${i}q;d"`
   set_hostname=$(printf "%s %s" "hostnamectl set-hostname" "${hostname}")
   new_script=$(printf "%s\n%s" "#!/bin/bash" "${set_hostname}")
   $(echo "${new_script}" > ${script2run})

   #copy the script into the remote machine and run it
   eval sshpass -p ${ssh_password} scp "${script2run}" "${host}:~/${host_dir}"
   ssh_cmd="sshpass -p ${ssh_password} ssh ${host} \"cd ${host_dir}; chmod 755 ${script2run}; nohup bash ./${script2run} >${script2run}.out 2>&1 &\""
   eval "${ssh_cmd}"
done
$(rm -f  ${script2run})

