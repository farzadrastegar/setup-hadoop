#!/bin/bash
rm /etc/yum.repos.d/mysql-community*
yum clean all
yum repolist
