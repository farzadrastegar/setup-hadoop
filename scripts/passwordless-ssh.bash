#!/bin/bash
USAGE="USAGE: ./passwordless-ssh.bash"

echo ${USAGE}
read -p "Press any key to continue" anykey
echo

printf "## Step 1: Create authentication keys\n"
echo "ssh-keygen -t rsa"
$(ssh-keygen -t rsa 2>&1)

printf "## Step 2: Upload generated public keys\n"
$(cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys)
$(cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys2)

printf "## Step 3: Set permissions on remote host\n"
$(chmod 700 ~/.ssh; chmod 640 ~/.ssh/authorized_keys; chmod 640 ~/.ssh/authorized_keys2)

printf "## Step 4: Disable SSH host key checking\n"
ssh_config=$(./lib/ssh-config.bash)
$(echo "${ssh_config}"  >> ~/.ssh/config)

printf "## Step 5: Finalize\n"
$(chmod 640 ~/.ssh/config)

printf "## Complete!\n"

