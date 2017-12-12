#!/bin/bash

## The following files have to exist in the same path
##   machine_ip: contains one line indicating what ip the machine should receive
##   machine_hostname: contains one line indicating what hostname the machine should receive

machine_ip=$(cat machine_ip)
machine_hostname=$(cat machine_hostname)

SYSCONFIG_NETWORK="/etc/sysconfig/network"
ETC_HOSTS="/etc/hosts"

# Setting up machine hostname"

#add two required lines
networkingLine="NETWORKING=yes"
hostnameLine="HOSTNAME=${machine_hostname}"
new_sysconfig_network=$(printf "%s\n%s\n%s" "${networkingLine}" "${hostnameLine}" "$(cat ${SYSCONFIG_NETWORK})")
echo "${new_sysconfig_network}" > ${SYSCONFIG_NETWORK}

#modify /etc/hosts
#new_etc_hosts=$(printf "%s\n%s %s" "$(cat ${ETC_HOSTS})" "${machine_ip}" "${machine_hostname}")
#echo "${new_etc_hosts}" > ${ETC_HOSTS}

