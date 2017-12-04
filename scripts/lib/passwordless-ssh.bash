#!/bin/bash
#USAGE="USAGE: ./passwordless-ssh.bash"

#echo ${USAGE}
#read -p "Press any key to continue" anykey
#echo

printf "## Step 1: Create authentication keys\n"
echo "ssh-keygen -t rsa"
eval ssh-keygen -t rsa 2>&1

printf "## Step 2: Upload generated public keys\n"
eval cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
eval cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys2

printf "## Step 3: Set permissions on remote host\n"
eval chmod 700 ~/.ssh; chmod 640 ~/.ssh/authorized_keys; chmod 640 ~/.ssh/authorized_keys2

printf "## Step 4: Disable SSH host key checking\n"
ssh_config=$(./lib/ssh-config.bash)
ssh_config_cmd="echo \"${ssh_config}\"  >> ~/.ssh/config"
eval "${ssh_config_cmd}"

printf "## Step 5: Finalize\n"
eval chmod 640 ~/.ssh/config

printf "## Complete!\n"

