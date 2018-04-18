#!/bin/bash
systemctl enable firewalld
systemctl start firewalld

firewall-cmd --add-service=dhcp --permanent
firewall-cmd --reload
systemctl restart dhcpd

firewall-cmd --add-service=tftp --permanent
firewall-cmd --reload
systemctl restart xinetd
systemctl restart tftp
