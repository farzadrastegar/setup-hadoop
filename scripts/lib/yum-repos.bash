#!/bin/bash
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
scp adminuser@master1.hadoopcluster.webranking:/etc/yum.repos.d/*.repo /etc/yum.repos.d
yum clean all
yum repolist
