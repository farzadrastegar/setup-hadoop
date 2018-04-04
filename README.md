# Instructions
A step-by-step tutorial on setting up a set of machines for Hortonworks Data Platform (HDP) and Ambari. This tutorial is specifically tested on Ambari 2.5.1.0 and HDP 2.6.1.0.

## Public Repositories:
Ambari 2.5.1.0: https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/ambari_repositories.html

HDP 2.6.1.0: https://docs.hortonworks.com/HDPDocuments/Ambari-2.5.1.0/bk_ambari-installation/content/hdp_26_repositories.html
 
## Installation steps
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

   \<usernames\> and \<ip-addresses\> represent two file names containing the root username and IP address of hadoop cluster nodes respectively. Each username or IP address reside in a separate line.

   3.2.3. Reboot all nodes.

         $ cp samples/reboot.bash .
         $ ./mypdsh.bash <usernames> <ip-addresses> reboot.bash

Before-doing-4. (If necessary) download jre/jdk rpm files and run the following script on the frontend machine to configure java repository for hadoop cluster nodes (Note: the script installs jdk-8u151-linux-x64.rpm).

         $ cp samples/install-java-jdk-8u151.bash .
         $ ./mypdsh.bash <usernames> <ip-addresses> install-java-jdk-8u151.bash

4. Run pre-ambari configurations.

   4.1. Configure all nodes.

   4.1.1. Change "$1", "$2", and "read" commands in pre1-ambari-setup.sh and name it pre1-noquestions-ambari-setup.sh.

   4.1.2. Run configurations on all nodes.

         $ ./mypdsh.bash <usernames> <ip-addresses> pre1-noquestions-ambari-setup.sh

   4.1.3. Reboot all nodes.

         $ ./mypdsh.bash <usernames> <ip-addresses> reboot.bash

   4.2. Validate configureations.

   4.2.1. Change "$1", "$2", and "read" commands in lib/pre1-test-ambari-setup.sh and name it pre1-noquestions-test-ambari-setup.sh.

   4.2.2. Run validations on all nodes.

         $ ./mypdsh.bash <usernames> <ip-addresses> pre1-noquestions-test-ambari-setup.sh

   4.2.3. See output at root@\<node-hostname\>:~/host-config/pre1-noquestions-test-ambari-setup.sh.out. There shouldn't be any "NOT" term in the file. Note: if transparent_hugepage is NOT disabled, use the script in samples/disable-transparent_hugepage-using-crontab.bash and reboot as follows.

         $ cp samples/disable-transparent_hugepage-using-crontab.bash .
         $ ./mypdsh.bash <usernames> <ip-addresses> disable-transparent_hugepage-using-crontab.bash
         $ ./mypdsh.bash <usernames> <ip-addresses> reboot.bash


5. Prepare Ambari/HDP repositories using the following URL in a machine called the repository server. This server that is configured to contain all the Ambari/HDP repositories is called 'master1.hadoopcluster.webranking' in our scripts laster on. This server is different from hadoop nodes. In other words, the frontend machine and the repository server could be considered as two virtual machines serving to configure the hadoop cluster. After setting up the repository server, make sure to copy the ~/.ssh directory from one of hadoop cluster nodes to the home directory of the repository server so that the nodes can ssh the repository server without password. 

    https://www.youtube.com/watch?v=usYJbMRXxew&index=4&list=PLhd4MmrFf8CXULSLNIxuoY49mVDGKlMk3

6. Prepare /etc/yum.repos.d in every node.

   6.1. Make a backup directory and move current repo files to it. Copy .repo files from the repository server, i.e. master1.hadoopcluster.webranking, to /etc/yum.repos.d.

         $ cp lib/yum-repos.bash .
         $ ./mypdsh.bash <usernames> <ip-addresses> yum-repos.bash

7. Install and start Ambari on a server node.

   7.0. Install database on master node. We use mysql here. The following link shows how to install mysql in Centos7.

    https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7

   7.0.1. Login to mysql and run the following commands to create necessary usernames and databases for ambari installation.

         $ mysql -u root -p
         mysql> CREATE USER 'ambari'@'<MASTER NODE HOSTNAME or IP HERE>' IDENTIFIED BY '<PASSWORD HERE>';
         mysql> GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'<MASTER NODE HOSTNAME or IP HERE>' WITH GRANT OPTION;
         mysql> CREATE USER 'ambari'@'%' IDENTIFIED BY '<PASSWORD HERE>';
         mysql> GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%' WITH GRANT OPTION;

         mysql> CREATE USER 'hive'@'<MASTER NODE HOSTNAME or IP HERE>' IDENTIFIED BY '<PASSWORD HERE>';
         mysql> GRANT ALL PRIVILEGES ON *.* TO 'hive'@'<MASTER NODE HOSTNAME or IP HERE>' WITH GRANT OPTION;
         mysql> CREATE USER 'hive'@'%' IDENTIFIED BY '<PASSWORD HERE>';
         mysql> GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%' WITH GRANT OPTION;

         mysql> FLUSH PRIVILEGES;
         mysql> CREATE DATABASE ambari;
         mysql> CREATE DATABASE hive;

   7.1. Install Ambari on a server node

         $ yum install ambari-server

   7.2. Initialize Ambari (installs Java by default). If you already installed Java on hadoop cluster nodes, skip this step and go to 7.2.1.

         $ ambari-server setup

   7.2.1. (Optional) In case you already installed Java on hadoop cluster nodes and would like to skip Java installation during initializing Ambari, use the following command instead of the command in 7.2.

         $ ambari-server setup -j /usr/java/default

   7.2.2. Say YES to the following question during the setup and enter database information if necessary.

         Enter advanced database configuration [y/n] (n)? y

   7.3. When you see the following message, enter the command mentioned below to fill up ambari database with the schema.

         Ambari Server 'setup' completed successfully.
         $ mysql -u ambari -p ambari < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql

   7.3.1. Download mysql JDBC connector jar file from this link (https://dev.mysql.com/downloads/connector/j/5.1.html) and copy it to /usr/share/java. We downloaded mysql-connector-java-5.1.46.jar.

         $ mv mysql-connector-java-5.1.46.jar /usr/share/java 
         $ ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java-5.1.46.jar

   7.3.2. Edit ambari.properties config file and add the following line to it.

         $ vim /etc/ambari-server/conf/ambari.properties
         (inside the file add a line as follows)
         server.jdbc.driver.path=/usr/share/java/mysql-connector-java-5.1.46.jar

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

