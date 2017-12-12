#!/bin/bash
rpm -qa | grep python | grep 2.7.5
echo "============"
wget ftp://10.1.228.22/pub/Packages/python-2.7.5-48.el7.x86_64.rpm
wget ftp://10.1.228.22/pub/Packages/python-libs-2.7.5-48.el7.x86_64.rpm
rpm -Uvh --oldpackage python-2.7.5-48.el7.x86_64.rpm python-libs-2.7.5-48.el7.x86_64.rpm
echo "================="
rpm -qa | grep python | grep 2.7.5
