# Instructions
A step-by-step tutorial on setting up a set of machines for Hortonworks Data Platform (HDP) and Ambari 

1. Install CentOS 7 on a machine that is in charge of installing hadoop cluster. We call this machine the "fontend machine".

   1.1. To install CentOS 7 using a flash disk, write the iso file onto the disk through the following command (/dev/sdc is the device associated with the flash disk in this example).

         $ dd if=CentOS-7-x86_64-Everything-1611.iso of=/dev/sdc

2. Setup a PXE-boot server on the frontend machine and install CentOS 7 on all hadoop cluster nodes.

   2.1. Run the following script to setup PXE boot server on the frontend machine. All the files and directories under the 'scripts' directory are required to run the script properly. Make sure that the 'CentOS-*-DVD-*.iso' file is available so that the script can mount and use it.

         $ ./pxe-boot-server.sh <machine-ip> <desired-hostname> <leftmost-ip-range> <rightmost-ip-range> <netmask>

    \<machine-ip\>: the IP address of the frontend machine, e.g. 192.168.10.10

    \<desired-hostname\>: a hostname for the frontend machine, e.g. pxe-server.myserver.com

    \<leftmost-ip-range\>: the leftmost range of the sets of IP addresses that PXE boot server makes available for hadoop cluster nodes, e.g. 192.168.10.120

    \<rightmost-ip-range\>: the rightmost range of the sets of IP addressed that PXE boot server makes available for hadoop cluster nodes, e.g. 192.168.10.160

    \<netmask\>: network netmask, e.g. 255.255.255.0

   2.1.1. (If necessary) download jre/jdk rpm files and run the following script on the frontend machine to configure java repository.

         $ cd lib
         $ ./java-repo.bash <pxe-server-ip> <jre rpm path> <jdk rpm path> <user@repo-server-ip>

   2.2. (If necessary) go to the BIOS menu of every machine in hadoop cluster and set them to boot from network (PXE boot enabled)
   Intel LAN Controller -> Enabled
   Intel PXE Option ROM -> ON

   2.3. Turn on all the machines and let them install CentOS through the PXE-boot server (the frontend machine).

   2.4. Setup network/IP configurations on all the nodes.

3. Setup pawssordless ssh and hostnames on all the nodes in hadoop cluster.

   3.1. Run the following script on the frontend machine.

         $ ./pre0-after-linux-installation.bash <usernames> <ip-addresses> <desired-hostnames>

   \<usernames\>: a filename containing the list of usernames each in a separate line. The usernames must indicate both the hadoop username and root on every machine. root usernames must be in even lines (line #2, #4, ...).

   \<ip-addresses\>: a filename containing the ip address of each machine in separate lines. Since the \<usernames\> filename has at least two usernames for each machine, the \<ip-addressess\> filename needs the same number of ip addresses duplicated for its corresponding username.

   \<desired-hostnames\>: a filename containing the correspnding hostnames of the ip addresses shown in the \<ip-addresses\> filename. 

   3.2. Add other nodes' hostnames to every node

   3.2.1. Modify add-cluster-hostnames.bash with IPs and hostnames of nodes and repo server (if any).
   3.2.2. Run the following commands.

         $ cp lib/add-cluster-hostnames.bash .
         $ ./mypdsh.bash <usernames> <ip-addresses> add-cluster-hostnames.bash

   \<usernames\>: root ONLY

   3.2.3. Reboot all nodes.

         $ ./mypdsh.bash <usernames> <ip-addresses> reboot.bash

4. Run pre-ambari configurations.

   4.1. Configure all nodes.

   4.1.1. Change "$1", "$2", and "read" commands in pre1-ambari-setup.sh and name it pre1-noquestions-ambari-setup.sh.
   4.1.2. Run configurations on all nodes.

         $ ./mypdsh.bash <usernames> <ip-addresses> pre1-noquestions-ambari-setup.sh

   4.2. Validate configureations.

   4.2.1. Change "$1", "$2", and "read" commands in lib/pre1-test-ambari-setup.sh and name it pre1-noquestions-test-ambari-setup.sh.
   4.2.2. Run validations on all nodes.

         $ ./mypdsh.bash <usernames> <ip-addresses> pre1-noquestions-test-ambari-setup.sh

   4.2.3. See output at root@\<node-hostname\>:~/host-config/pre1-noquestions-test-ambari-setup.sh.out. There shouldn't be any "NOT" term in the file.

5. Prepare Ambari/HDP repositories using the following URL in a machine called the repository server. This server that is configured to contain all the Ambari/HDP repositories is called 'master1.hadoopcluster.webranking' in our scripts laster on. This server is separated from hadoop nodes. In other words, the frontend machine and the repository server could be two virtual machines serving to configure the hadoop cluster.
https://www.youtube.com/watch?v=usYJbMRXxew&index=4&list=PLhd4MmrFf8CXULSLNIxuoY49mVDGKlMk3

6. Prepare /etc/yum.repos.d in every node.

   6.1. Make a backup directory and move current repo files to it. Copy .repo files from the repository server, i.e. master1.hadoopcluster.webranking, to /etc/yum.repos.d.

         $ cp lib/yum-repos.bash .
         $ ./mypdsh.bash <usernames> <ip-addresses> yum-repos.bash

7. Install and start Ambari on a server node.

   7.1. Install Ambari on a server node

         $ yum install ambari-server

   7.2. Initialize Ambari (installs Java by default). 

         $ ambari-server setup

   7.3 (Optional) After running the command above, choose the "Custom JDK" option in case you would like to bypass java installation and enter the path of Java_HOME yourself. In a separate terminal window use the following command to find your JAVA_HOME path and use the output of the command for JAVA_HOME during Ambari installation.

         $ ls -ltr $(ls -ltr $(which java) | awk '{print $NF}') | awk '{print $NF}' | sed 's/bin/bin /g' | cut -d' ' -f1

   7.4. Start Ambari server

         $ ambari-server start

   7.5. Go to the following URL (user:admin, pass:admin)

   http://localhost:8080

8. Install Hortonworks Data Platform (HDP) on hadooop nodes.

   8.1. Using the node where Ambari is installed, go to the following URL (user:admin, pass:admin)

   http://localhost:8080

   8.2. Click on 'Launch Install Wizard'

   8.3. Give a name to cluster and click Next

   8.4. Select 'Advanced Repository Options'

   8.5. Base on your operating system edit the links to your HDP and HDP-UTILS local server paths and uncheck other checkboxes

   8.6. On the 'Install Options' page, copy/paste hosts from /etc/hosts and remove IPs

   8.7. Give the path to the SSH private key and provide username.

   8.8. Click on 'Replace and Confirm'

   8.9. Next page installs HDP for all the nodes in the cluster

   8.10. Take care of warning messages (if necessary). Click Next

   8.11. Choose Services (e.g. HDFS, Yarn, Ambari Metrics, Spark, ZooKeeper, Tez, Hive)

   8.12. Next, 'Assign Masters'

   Example:

--History Server ->master

--App Timeline Server ->master

--Resource Manager ->master

--Hive Metastore ->master

--HiveServer2 ->master

--ZooKeeper Server->slave1

--ZooKeeper Server->master

--Metrics Collector->master

--Spark History Server ->master

   8.13. Next, 'Assign Slaves and Clients'

Example:

--master ->Client

--Slave1 ->DataNode, NodeManager, Spark Thrift Server

--Slave2 ->DataNode, NodeManager, Spark Thrift Server

   8.14. Next, 'Customize Services': if there is any config issue, resolve them. Also, take care of warning messages.

   8.15. Next, deploy the cluster. Be patient, it takes a long time.

   8.16. Take care of warning messages (if necessary)

   8.17. Next, you see the dashboard of Ambari


# Future work for automation
- [ ] Automate CentOS registration confirmation
- [ ] Automate answering to boot up questions (location, ...)
- [ ] Automate creating usernames throughout booting
- [ ] Automate network settings (gateway, dns, ...)

# Note
A. If 'yum update' is among post package processings, you might need to run the 'dhclient' command before updating just to make sure the machine has a valid IP. 

