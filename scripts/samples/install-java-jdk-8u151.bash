#!/bin/bash

# extract how many java options exist already
javaOption=`alternatives --display java | grep ^/ | wc -l`
((javaOption++))

java -version

wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.rpm"

yum localinstall jdk-8u151-linux-x64.rpm
alternatives --config java <<< ${javaOption}

sh -c "echo export JAVA_HOME=/usr/java/jdk1.8.0_151/jre >> ~/.bashrc"
sh -c "echo export JAVA_HOME=/usr/java/jdk1.8.0_151/jre >> /etc/environment"

java -version

