#!/bin/bash

# suppose we need to install 'jre-8u151-linux-x64.rpm' and 'jdk-8u151-linux-x64.rpm' for java

# install the intended package (this package will not be listed with command 'rpm -qa' afterwards)
rpm -Uvh jre-8u151-linux-x64.rpm jdk-8u151-linux-x64.rpm

# remove all installed and listed java packages including their dependencies
rpm -qa | grep ^java- | xargs yum -y remove

# now java version should be the intended one
java -version
