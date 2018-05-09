#!/bin/bash
javahome=`ls -ltr $(ls -ltr $(which java) | awk '{print $NF}') | awk '{print $NF}' | sed 's/\/bin/ \/bin/g' | cut -d' ' -f1`
sed -i "s/^export JAVA_HOME=\/usr\/java\/default/export JAVA_HOME=$(echo $javahome | sed 's/\//\\\//g')/" ~/.bashrc
sed -i "s/^export JAVA_HOME=\/usr\/java\/default/export JAVA_HOME=$(echo $javahome | sed 's/\//\\\//g')/" /etc/environment
source ~/.bashrc

