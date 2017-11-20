#!/bin/bash
USAGE="USAGE: ./passwordless-ssh.bash \"user@remote-host-ip\""
DIR=$(pwd)

echo ${USAGE}
read -p "Press any key to continue" anykey
echo

if [[ $# -ne 1 ]]; then
   echo "Error: wrong number of arguments!"
   echo ${USAGE}
   exit 1
fi

remote_host=$1

printf "## Step 1: Create authentication keys\n"
echo "ssh-keygen -t rsa"
$(ssh-keygen -t rsa 2>&1)

printf "## Step 2: Create .ssh Directory on remote host\n"
$(ssh ${remote_host} mkdir -p .ssh)

printf "## Step 3: Upload generated public keys\n"
$(cat ~/.ssh/id_rsa.pub | ssh ${remote_host} 'cat > .ssh/tmp-public-key')
#$(cat ~/.ssh/id_rsa.pub | ssh ${remote_host} 'cat >> .ssh/authorized_keys')
#$(cat ~/.ssh/id_rsa.pub | ssh ${remote_host} 'cat >> .ssh/authorized_keys2')

printf "## Step 4: Set permissions on remote host\n"
$(ssh ${remote_host} "cat .ssh/tmp-public-key >> .ssh/authorized_keys; cat .ssh/tmp-public-key >> .ssh/authorized_keys2; rm .ssh/tmp-public-key; chmod 700 .ssh; chmod 640 .ssh/authorized_keys; chmod 640 .ssh/authorized_keys2")

printf "## Step 5: Disable SSH host key checking\n"
ssh_config=$(./lib/ssh-config.bash)
$(echo "${ssh_config}" | ssh ${remote_host} 'cat >> .ssh/config')

printf "## Step 6: Finalize\n"
$(ssh ${remote_host} "chmod 640 .ssh/config")
$(scp ~/.ssh/id_rsa* ${remote_host}:~/.ssh)

printf "## Complete!\n"

