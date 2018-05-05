#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

USAGE="./pre1-test-ambari-setup.bash \"grid-disks-roots-separated-with-pipes\" <hadoop-username>"
SYSCTL_CONF="/etc/sysctl.conf"
FSTAB="/etc/fstab"
SUDOERS="/etc/sudoers"
TRANSPARENT_HUGEPAGE="/sys/kernel/mm/transparent_hugepage/enabled"
DISABLE_IPV6="/proc/sys/net/ipv6/conf/all/disable_ipv6"
LIMITS_CONF="/etc/security/limits.conf"

echo "${USAGE}"
read -p "Press any key to continue" anykey
echo

grid_disks=$1
hadoop_username=$2
hadoop_group="hadoop"

## basic platform detection
lsb_dist=''
if [ -r /etc/centos-release ]; then
    lsb_dist="centos"
    lsb_dist_release=$(awk '{print $(NF-1)}' /etc/centos-release | cut -d "." -f1)
elif [ -r /etc/redhat-release ]; then
    lsb_dist="centos"
    lsb_dist_release=$(awk '{print $(NF-1)}' /etc/redhat-release | cut -d "." -f1)
elif [ -r /etc/os-release ] && [ $(awk '$1=="ID" {gsub("\"", ""); print $2}' FS='=' /etc/os-release) == "amzn" ]; then
    lsb_dist="centos"
    lsb_dist_release=6
fi

lsb_dist="$(echo "${lsb_dist}" | tr '[:upper:]' '[:lower:]')"

verify_with_user() {
   filename=$1
   content=$2

   echo "New ${filename} is:"
   echo "========================"
   echo "${content}"
   echo "========================"
   read -p "Does it look OK?(y/n) " response

   while [[ ( "${response}" != "y" ) && ( "${response}" != "n" ) ]]; do
      read -p "Does it look OK?(y/n) " response
   done

   if [[ ( "${response}" == "n" ) ]]; then
      exit 1
   fi
   echo
}

case "${lsb_dist}" in
    centos|redhat)

    case "${lsb_dist_release}" in
        6|7)

        (
            set +o errexit

            printf "## Info: Test of disabled IPv6\n"
            cat ${DISABLE_IPV6} | grep 1 >/dev/null && echo "IPv6 is disabled" || echo "IPv6 is NOT disabled"

            printf "## Info: Test of passwordless sudo\n"
            groups ${hadoop_username} | grep wheel >/dev/null && echo "${hadoop_username} is sudoer" || echo "${hadoop_username} is NOT sudoer"
            #wheel_nopasswd=$(printf "%s\t%s\t%s" "%wheel" "ALL=(ALL)" "NOPASSWD: ALL")
            cat ${SUDOERS} | grep "^%wheel	ALL=(ALL)	NOPASSWD: ALL" >/dev/null && echo "Passwordless sudo is ON" || echo "Passwordless sudo is OFF"
            #eval "${check_passwordless}"

            printf "## Info: Test of disabled selinux\n"
            sestatus 2>/dev/null | grep "SELinux status" | grep "enabled" >/dev/null && echo "SELinux is NOT disabled" || echo "SELinux is disabled"

            printf "## Info: Test of disabled Transparent Huge Pages\n"
            cat ${TRANSPARENT_HUGEPAGE} | grep "\[never\]" >/dev/null && echo "Transparent Huge Pages is disabled" || echo "Transparent Huge Pages is NOT disabled"

            printf "## Info: Test of disabled iptables & firewall\n"
            systemctl status iptables
            echo "==============="
            systemctl status firewalld
            echo "==============="

            printf "## Info: Testing ntpd\n"
            systemctl status ntpd
            echo "==============="

            printf "## Info: Test of file handlers & processes\n"
            cat ${LIMITS_CONF} | grep -E '^hdfs|^mapred|^hbase' && echo "Configurations found" || echo "Configurations NOT found"
            echo "==============="
        )

        printf "## Info: Test of groups configuration\n"
        groups ${hadoop_username} | grep ${hadoop_group} >/dev/null && echo "Groups configuration passed" || echo "Groups NOT configured"

        printf "## Info: Test of swappiness\n"
        cat ${SYSCTL_CONF} | grep "vm.swappiness = 0" && echo "swapiness is disabled" || echo "swapiness is NOT disabled"

        printf "## Info: Test of enabled overcommitting of virtual memory\n"
        cat ${SYSCTL_CONF} | grep "vm.overcommit" && echo "===============" || echo "overcommitting is NOT enabled"

        printf "## Info: Test of hadoop disks 'noatime'\n"
        cat ${FSTAB} | grep noatime && echo "================" || echo "noatime NOT found"

        printf "## Info: Check reserved space on hadoop disks\n"
        for dev in `df | egrep ${grid_disks} | awk '{print $1}' 2>/dev/null`; do
            echo ${dev}
            check_reserved_block="dumpe2fs -h ${dev} 2> /dev/null | awk -F ':' '{ if(\$1 == \"Reserved block count\") { rescnt=\$2 } } { if(\$1 == \"Block count\") { blkcnt=\$2 } } END { print \"Reserved blocks: \"(rescnt/blkcnt)*100\"%\" }'"
            eval "${check_reserved_block}"
        done
        
        printf "## Info: Check Java version\n"
        java -version
        echo "==============="
        
        printf "## Success! All done.\n"
        exit 0
    ;;
    esac
;;
esac

cat >&2 <<'EOF'

  Your platform is not currently supported by this script or was not
  easily detectable.

  The script currently supports:
    Red Hat Enterprise Linux 6 & 7
    CentOS 6 & 7
EOF
exit 1

