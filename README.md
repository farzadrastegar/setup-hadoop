# Instructions
A step-by-step tutorial on setting up a set of machines for Hortonworks Data Platform (HDP) and Ambari 

1. Install CentOS 7 on a machine that is in charge of installing hadoop cluster. We call this machine the "fontend machine".

   1.1. To install CentOS 7 using a flash disk, write the iso file onto the disk through the following command (/dev/sdc is the device associated with the flash disk in this example).
```
   $ dd if=CentOS-7-x86_64-Everything-1611.iso of=/dev/sdc
```

2. Setup a PXE-boot server on the frontend machine and install CentOS 7 on all hadoop cluster nodes.

   2.1. Run the following script to setup PXE boot server on the frontend machine. All the files and directories under the 'scripts' directory are required to run the script properly. Make sure that the 'CentOS-*-DVD-*.iso' file is available so that the script can mount and use it.
```
   $ ./pxe-boot-server.sh <machine-ip> <desired-hostname> <leftmost-ip-range> <rightmost-ip-range> <netmask>
```
   ```<machine-ip>```: the IP address of the frontend machine, e.g. 192.168.10.10
   ```<desired-hostname>```: a hostname for the frontend machine, e.g. pxe-server.myserver.com
   ```<leftmost-ip-range>```: the leftmost range of the sets of IP addresses that PXE boot server makes available for hadoop cluster nodes, e.g. 192.168.10.120
   ```<rightmost-ip-range>```: the rightmost range of the sets of IP addressed that PXE boot server makes available for hadoop cluster nodes, e.g. 192.168.10.160
   ```<netmask>```: network netmask, e.g. 255.255.255.0

        2.1.1. (If necessary) download jre/jdk rpm files and run the following script on the frontend machine to configure java repository.
```
        $ cd lib
        $ ./java-repo.bash <pxe-server-ip> <jre rpm path> <jdk rpm path> <user@repo-server-ip>
```

   2.2. (If necessary) go to the BIOS menu of every machine in hadoop cluster and set them to boot from network (PXE boot enabled)
   Intel LAN Controller -> Enabled
   Intel PXE Option ROM -> ON

   2.3. Turn on all the machines and let them install CentOS through the PXE-boot server (the frontend machine).

   2.4. Setup network/IP configurations on all the nodes.

3. Setup pawssordless ssh and hostnames on all the nodes in hadoop cluster.

   3.1. Run the following script on the frontend machine.
```
   $ ./pre0-after-linux-installation.bash <usernames> <ip-addresses> <desired-hostnames>
```
   <usernames>: a filename containing the list of usernames each in a separate line. The usernames must indicate both the hadoop username and root on every machine. root usernames must be in even lines (line #2, #4, ...).
   <ip-addresses>: a filename containing the ip address of each machine in separate lines. Since the <usernames> filename has at least two usernames for each machine, the <ip-addressess> filename needs the same number of ip addresses duplicated for its corresponding username.
   <desired-hostnames>: a filename containing the correspnding hostnames of the ip addresses shown in the <ip-addresses> filename.
 
   3.2. Add other nodes' hostnames to every node
        3.2.1. Modify add-cluster-hostnames.bash with IPs and hostnames of nodes and repo server (if any).
        3.2.2. Run the following commands.
```
        $ cp lib/add-cluster-hostnames.bash .
        $ ./mypdsh.bash <usernames> <ip-addresses> add-cluster-hostnames.bash
```
        <usernames>: root ONLY
        3.2.3. Reboot all nodes.
```
        $ ./mypdsh.bash <usernames> <ip-addresses> reboot.bash
```

4. Run pre-ambari configurations.

   4.1. Configure all nodes.
        4.1.1. Change "$1", "$2", and "read" commands in pre1-ambari-setup.sh and name it pre1-noquestions-ambari-setup.sh.
        4.1.2. Run configurations on all nodes.
```
        $ ./mypdsh.bash <usernames> <ip-addresses> pre1-noquestions-ambari-setup.sh
```

   4.2. Validate configureations.
        4.2.1. Change "$1", "$2", and "read" commands in lib/pre1-test-ambari-setup.sh and name it pre1-noquestions-test-ambari-setup.sh.
        4.2.2. Run validations on all nodes.
```
        $ ./mypdsh.bash <usernames> <ip-addresses> pre1-noquestions-test-ambari-setup.sh
```
        4.2.3. See output at root@<node-hostname>:~/host-config/pre1-noquestions-test-ambari-setup.sh.out. There shouldn't be any "NOT" term in the file.

5. Prepare /etc/yum.repos.d in every node.

   5.1. Make a backup directory and move current repo files to it. Copy .repo files from repository server to /etc/yum.repos.d.
```
   $ cp lib/yum-repos.bash .
   $ ./mypdsh.bash <usernames> <ip-addresses> yum-repos.bash
```

# Future work for automation
A. Automate CentOS registration confirmation
B. Automate answering to boot up questions (location, ...)
C. Automate creating usernames throughout booting
D. Automate network settings (gateway, dns, ...)

# Note
A. If 'yum update' is among post package processings, you might need to run the 'dhclient' command before updating just to make sure the machine has a valid IP. 

