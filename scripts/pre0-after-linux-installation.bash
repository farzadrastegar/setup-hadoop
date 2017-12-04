#!/bin/bash
USAGE="USAGE: ./pre0-after-linux-installation.bash <usernames> <machines IPs> <desired hostnames>"
echo "${USAGE}"
read -p "Press any key to continue..." anykey

# input arguments
users=$1
ips=$2
hostnames=$3

# Variables
ssh_exists=0
ssh_dir=".ssh"
original_ssh_targz="orig-ssh.tar.gz"
new_ssh_targz="new-ssh.tar.gz"
curdir="$(pwd)"
host_dir="host-config"
ssh_key="~/.ssh/id_rsa"

### Setting up passwordless SSH ###
eval cd

# Backup current .ssh directory
if [[ -d "${ssh_dir}" ]]; then
   echo "Backing up .ssh ..."
   ssh_exists=1
   eval tar cvzf ${original_ssh_targz} ${ssh_dir} >/dev/null 2>&1
   eval rm -fr ${ssh_dir}
fi

eval cd ${curdir}

# Create new .ssh directory
echo "creating new .ssh (press enter when necessary)"
eval lib/passwordless-ssh.bash
service sshd stop
service sshd start
chkconfig sshd on

eval cd

# Zip the created .ssh
rm -f ${new_ssh_targz}
eval tar cvzf ${new_ssh_targz} ${ssh_dir} >/dev/null 2>&1

eval cd ${curdir}

# Transfer new ssh to all machines
i=0
for host in `paste -d'@' ${users} ${ips} 2>/dev/null`; do 
   userATip[$i]=${host}
   ((i++))

   echo "Connecting ${host}..."
   eval scp "~/${new_ssh_targz}" "${host}:~"
   ssh_cmd="ssh ${host} \"rm -fr .ssh; tar xvzf ${new_ssh_targz}; rm ${new_ssh_targz}; mkdir -p ${host_dir}\""
   eval "${ssh_cmd}"
   eval scp -i ${ssh_key} lib/remote-host-config.bash "${host}:~/${host_dir}"
done
###################################

echo ${userATip[@]}

### Setting up hostname ###
host_filename="machine_hostname"
ip_filename="machine_ip"

echo "prepare the machine_hostname file"
i=0
for machine_hostname in `cat ${hostnames} 2>/dev/null`; do 
   cmd="echo ${machine_hostname} | ssh -i ${ssh_key} ${userATip[$i]} 'cat > ${host_dir}/${host_filename}'"
   echo "${cmd}"
   eval "${cmd}"
   ((i++))
done	

echo "prepare the machine_ip file"
i=0
for machine_ip in `cat ${ips} 2>/dev/null`; do 
   cmd="echo ${machine_ip} | ssh -i ${ssh_key} ${userATip[$i]} 'cat > ${host_dir}/${ip_filename}'"
   echo "${cmd}"
   eval "${cmd}"
   ((i++))
done	

echo "run script in the remote machine"
len=${#userATip[*]}
for (( i=1; i<len; i+=2 ))
do
   ssh_cmd="ssh -i ${ssh_key} ${userATip[$i]} \"cd ${host_dir}; bash ./remote-host-config.bash\""
   echo "${ssh_cmd}"
   eval "${ssh_cmd}"
done


###########################

