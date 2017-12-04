#!/bin/bash
USAGE="USAGE: ./hostname-config.bash <machine-ip> <desired-hostname>"

echo "${USAGE}"
read -p "Press any key to continue" anykey
echo

#machine_ip=$1
#machine_hostname=$2
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
new_etc_hosts=$(printf "%s\n%s %s" "$(cat ${ETC_HOSTS})" "${machine_ip}" "${machine_hostname}")
echo "${new_etc_hosts}" > ${ETC_HOSTS}

