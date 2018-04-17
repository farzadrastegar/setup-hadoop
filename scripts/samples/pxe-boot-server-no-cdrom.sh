#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

SYSCONFIG_NETWORK="/etc/sysconfig/network"
ETC_HOSTS="/etc/hosts"
DHCPD_CONF="/etc/dhcp/dhcpd.conf"
VAR_FTP_PUB="/var/ftp/pub"
#DEV_CDROM="/dev/cdrom"
DEV_CDROM="/root/Downloads/CentOS-7-x86_64-Everything-1611.iso"
YUM_REPOS="/etc/yum.repos.d"
XINETD_TFTP="/etc/xinetd.d/tftp"
VAR_LIB_TFTPBOOT="/var/lib/tftpboot"

USAGE="USAGE: ./pxe-boot-server.sh <machine-ip> <desired-hostname> <leftmost-ip-range> <rightmost-ip-range> <netmask>"

iptables_disable="${iptables_disable:-true}"

network_device="eth0"

echo "${USAGE}"
read -p "Press any key to continue" anykey
echo

machine_ip=$1
machine_hostname=$2
leftmost_ip_range=$3
rightmost_ip_range=$4
netmask=$5

check_arguments_validity() {
echo $#
   if [[ $# -ne 1 ]]; then
      echo ${USAGE}
      exit 1
   fi
}

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

case "${lsb_dist}" in
    centos|redhat)

    case "${lsb_dist_release}" in
        6|7)

        (
            set +o errexit

            #printf "## Info: Installing anti-filter packages\n"
            #yum install -y -q epel-release NetworkManager-openconnect

            printf "## Info: Installing base packages\n"
            yum install -y -q vsftpd dhcp tftp-server xinetd syslinux

            printf "## Info: Setting up machine hostname\n"
            #add two required lines
            networkingLine="NETWORKING=yes" 
            hostnameLine="HOSTNAME=${machine_hostname}"
            new_sysconfig_network=$(printf "%s\n%s\n%s" "${networkingLine}" "${hostnameLine}" "$(cat ${SYSCONFIG_NETWORK})")
            verify_with_user "${SYSCONFIG_NETWORK}" "${new_sysconfig_network}"
            
            #write to file
            $(echo "${new_sysconfig_network}" > ${SYSCONFIG_NETWORK})

            #modify /etc/hosts
            new_etc_hosts=$(printf "%s\n%s %s" "$(cat ${ETC_HOSTS})" "${machine_ip}" "${machine_hostname}")
            verify_with_user "${ETC_HOSTS}" "${new_etc_hosts}"

            #write to file
            $(echo "${new_etc_hosts}" > ${ETC_HOSTS})

#            printf "## Info: Fixing sudo to not requiretty. This is the default in newer distributions\n"
#            printf 'Defaults !requiretty\n' > /etc/sudoers.d/888-dont-requiretty

            printf "## Info: Disabling selinux\n"
            setenforce 0 || true
            sed -i 's/\(^[^#]*\)SELINUX=enforcing/\1SELINUX=disabled/' /etc/selinux/config
            sed -i 's/\(^[^#]*\)SELINUX=permissive/\1SELINUX=disabled/' /etc/selinux/config

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

            printf "## Info: Configuring DHCP server\n"
            subnet=$(echo ${machine_ip} | awk -F'.' '{print $1"."$2"."$3".0"}')
            new_dhcpd_conf=$(printf "%s\n%s" "$(cat ${DHCPD_CONF})" "$(./lib/dhcp-config.bash ${machine_ip} ${leftmost_ip_range} ${rightmost_ip_range} ${netmask})")
            verify_with_user "${DHCPD_CONF}" "${new_dhcpd_conf}"

            #write to file
            $(echo "${new_dhcpd_conf}" > ${DHCPD_CONF})

            printf "## Info: Mounting DVD & copying files\n"
            printf "Please put the linux DVD into the DVD-ROM\n"
            read -p "Enter the full path where the linux DVD is mounted to: " mount_path
            #mount -loop ${DEV_CDROM} ${mount_path}
            mount -o loop ${DEV_CDROM} ${mount_path}
            chmod 777 ${VAR_FTP_PUB}
            cp -Rvf ${mount_path}/* ${VAR_FTP_PUB}
            cp ${mount_path}/isolinux/* ${VAR_LIB_TFTPBOOT}
            cp /usr/share/syslinux/pxelinux.0 ${VAR_LIB_TFTPBOOT}

            #create a 'default' file in pxelinux.cfg and configure it
            mkdir -p ${VAR_LIB_TFTPBOOT}/pxelinux.cfg
            cp ${VAR_LIB_TFTPBOOT}/isolinux.cfg ${VAR_LIB_TFTPBOOT}/pxelinux.cfg/default
            new_default="sed -i '/^label linux/,/^label/{ s/^\\([ \\t]*\\)append initrd=initrd.img.*/\\1append initrd=initrd.img linux ks=ftp:\\/\\/${machine_ip}\\/pub\\/ks.cfg/}' ${VAR_LIB_TFTPBOOT}/pxelinux.cfg/default"
            eval "${new_default}"

            #create kickstart config file
            read -p "Enter the kickstart bash filename in the lib directory: " kickstart_config
            kickstart_conf=$(printf "%s" "$(./lib/${kickstart_config} ${machine_ip} ${network_device})")
            $(echo "${kickstart_conf}" > ${VAR_FTP_PUB}/ks.cfg)

            #unmount DVD-ROM
            umount ${mount_path}

            printf "## Info: Creating repository\n"
            pxe_repo=$(printf "%s" "$(./lib/pxe-repo.bash ${machine_ip})")
            pxe_repo_path="${YUM_REPOS}/pxe.repo"
            verify_with_user "${pxe_repo_path}" "${pxe_repo}"

            #write to file
            $(echo "${pxe_repo}" > ${pxe_repo_path})

            service vsftpd start
            yum clean all
            yum repolist
            #yum install telnet-server && echo "Creating repository completed!" || echo "repository NOT working!"

            printf "## Info: Enabling TFTP-server\n"
            sed -i 's/\(^[^#]*\)disable\([ \t]*\)=\([ \t]*\)yes/\1disable\2=\3no/' ${XINETD_TFTP}

            printf "## Info: Enabling all required services\n"
            for servicename in dhcpd vsftpd xinetd; do
                service ${servicename} stop
                service ${servicename} start
                chkconfig ${servicename} on
            done
        )

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

