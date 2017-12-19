#!/bin/bash
java -version

wget ftp://10.1.228.22/pub/Packages/*8u151-linux-x64.rpm
yum localinstall jre-8u151-linux-x64.rpm -y
yum localinstall jdk-8u151-linux-x64.rpm -y
yum remove java-1.8.0-openjdk-1.8.0.102-4.b14.el7.x86_64 -y
yum remove java-1.8.0-openjdk-headless-1.8.0.102-4.b14.el7.x86_64 -y
yum remove java-1.7.0-openjdk-1.7.0.111-2.6.7.8.el7.x86_64 -y
yum remove java-1.7.0-openjdk-headless-1.7.0.111-2.6.7.8.el7.x86_64 -y

java -version

