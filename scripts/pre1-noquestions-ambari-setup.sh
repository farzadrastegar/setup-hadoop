#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

USAGE="./pre-ambari-setup.bash \"grid-disks-roots-separated-with-pipes\" <hadoop-username>"
SYSCTL_CONF="/etc/sysctl.conf"
FSTAB="/etc/fstab"
LIMITS_CONF="/etc/security/limits.conf"
SUDOERS="/etc/sudoers"

iptables_disable="${iptables_disable:-true}"
java_provider="${java_provider:-open}" # accepts: open, oracle
java_version="${java_version:-8}"

echo "${USAGE}"
#read -p "Press any key to continue" anykey
#echo

grid_disks="grid"
hadoop_username="hduser"
hadoop_group="hadoop"

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

check_firewall() {
type_firewall=$(yum list installed | egrep ^firewalld)
if [ -n "${type_firewall}" ]; then
    ver_firewall="firewalld"
else
    ver_firewall="iptables"
fi
ver_firewall="$(echo "${ver_firewall}" | tr '[:upper:]' '[:lower:]')"
}

if [ ! "$(hostname -f)" ]; then
    printf >&2 'Error: "hostname -f" failed to report an FQDN.\n'
    printf >&2 'The system must report a FQDN in order to use Ambari\n'
    exit 1
fi

if [ "$(id -ru)" != 0 ]; then
    printf >&2 'Error: this installer needs the ability to run commands as root.\n'
    printf >&2 'Install as root or with sudo\n'
    exit 1
fi

case "$(uname -m)" in
    *64)
        ;;
    *)
        printf >&2 'Error: you are not using a 64bit platform.\n'
        printf >&2 'This installer requires a 64bit platforms.\n'
        exit 1
        ;;
esac

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

if command_exists ambari-agent || command_exists ambari-server; then
    printf >&2 'Warning: "ambari-agent" or "ambari-server" command appears to already exist.\n'
    printf >&2 'Please ensure that you do not already have ambari-agent installed.\n'
    printf >&2 'You may press Ctrl+C now to abort this process and rectify this situation.\n'
    ( set -x; sleep 20 )
fi

my_disable_thp() {
    ( cat > /usr/local/sbin/ambari-thp-disable.sh <<-'EOF'
#!/usr/bin/env bash
# disable transparent huge pages: for Hadoop
thp_disable=true
if [ "${thp_disable}" = true ]; then
    for path in redhat_transparent_hugepage transparent_hugepage; do
        for file in enabled defrag; do
            if test -f /sys/kernel/mm/${path}/${file}; then
                echo never > /sys/kernel/mm/${path}/${file}
            fi
        done
    done
fi
exit 0
EOF
    )
    chmod +x /usr/local/sbin/ambari-thp-disable.sh
    sh /usr/local/sbin/ambari-thp-disable.sh
    printf '\nsh /usr/local/sbin/ambari-thp-disable.sh || /bin/true\n\n' >> /etc/rc.local
}

my_disable_ipv6() {
    mkdir -p /etc/sysctl.d
    ( cat > /etc/sysctl.d/99-hadoop-ipv6.conf <<-'EOF'
## Disabled ipv6
## Provided by Ambari Bootstrap
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
    )
    sysctl -e -p /etc/sysctl.d/99-hadoop-ipv6.conf
}

verify_with_user() {
   filename=$1
   content=$2

   echo "New ${filename} is:"
   echo "========================"
   echo "${content}"
   echo "========================"
#   read -p "Does it look OK?(y/n) " response
   response="y"

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

            printf "## Info: Disabling IPv6\n"
            my_disable_ipv6

            printf "## Info: Installing base packages\n"
            yum install -y -q curl ntp openssl python zlib wget unzip openssh-clients httpd

            printf "## Info: Fixing sudo to not requiretty. This is the default in newer distributions\n"
            printf 'Defaults !requiretty\n' > /etc/sudoers.d/888-dont-requiretty

            printf "## Info: Disabling selinux\n"
            setenforce 0 || true
            sed -i 's/\(^[^#]*\)SELINUX=enforcing/\1SELINUX=disabled/' /etc/selinux/config
            sed -i 's/\(^[^#]*\)SELINUX=permissive/\1SELINUX=disabled/' /etc/selinux/config

            printf "## Info: Disabling Transparent Huge Pages\n"
            my_disable_thp

            printf "## Info: Disabling iptables & firewall\n"
            if [ "${iptables_disable}" = true ]; then
                check_firewall
                case "${ver_firewall}" in
                    firewalld)
                        printf "## Info: Disabling firewalld\n"
                        systemctl disable firewalld || true
                        systemctl stop firewalld || true
                    ;;
                    iptables)
                        printf "## Info: Disabling iptables\n"
                        chkconfig iptables off || true
                        service iptables stop || true
                        chkconfig ip6tables off || true
                        service ip6tables stop || true
                     ;;
                esac
            fi

            printf "## Info: Syncing time via ntpd\n"
            ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime
            ntpd -qg || true
            chkconfig ntpd on || true
            service ntpd restart || true

            printf "## Info: Setting up file handlers & processes\n"
            new_limits_conf=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n%s" "$(cat ${LIMITS_CONF})" "hdfs – nofile 32768" "hdfs – nproc 32768" "mapred – nofile 32768" "mapred – nproc 32768" "hbase – nofile 32768" "hbase – nproc 32768")
            verify_with_user "${LIMITS_CONF}" "${new_limits_conf}"
            #write to file
            $(echo "${new_limits_conf}" > ${LIMITS_CONF})
    
            printf "## Info: Setting up groups and passwordless sudo\n"
            $(groupadd ${hadoop_group} 2>/dev/null)
            $(usermod -aG wheel,${hadoop_group} ${hadoop_username})
            wheel_nopasswd=$(printf "%s\t%s\t%s" "%wheel" "ALL=(ALL)" "NOPASSWD: ALL")
            $(echo "${wheel_nopasswd}" >> ${SUDOERS})    
        )

        if [ "${java_provider}" != 'oracle' ]; then
            printf "## Info: Installing java\n"
            yum install -q -y java-1.${java_version}.0-openjdk-devel
            mkdir -p /usr/java
            ln -sf /etc/alternatives/java_sdk /usr/java/default
            #update-alternatives --set java /usr/lib/jvm/jre-1.${java_version}.0-openjdk/bin/java
            JAVA_HOME='/usr/java/default'
        fi

        printf "## Info: Disabling swappiness\n"
        swappiness="vm.swappiness = 0"

        printf "## Info: Enabling overcommitting of virtual memory\n"
        overcommit=$(printf "%s\n%s" "vm.overcommit_memory = 1" "vm.overcommit_ratio = 50")

        new_sysctl_conf=$(printf "%s\n%s\n%s" "$(cat ${SYSCTL_CONF})" "${swappiness}" "${overcommit}")
        verify_with_user "${SYSCTL_CONF}" "${new_sysctl_conf}"
        #write to file
        $(echo "${new_sysctl_conf}" > ${SYSCTL_CONF})

        printf "## Info: Making hadoop disks 'noatime'\n"
        new_fstab_command=$(echo "cat ${FSTAB} | awk '{ if (\$0 ~ /${grid_disks}/) {sub(/defaults/, \"defaults,noatime\"); print} else {print} }'")
        new_fstab=$(eval ${new_fstab_command})
        verify_with_user "${FSTAB}" "${new_fstab}"
	#write to file
        $(echo "${new_fstab}" > ${FSTAB})

        printf "## Info: Eliminating reserved space\n"
        for dev in `df | egrep ${grid_disks} | awk '{print $1}' 2>/dev/null`; do 
           tune2fs -m 0 ${dev}
        done

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

