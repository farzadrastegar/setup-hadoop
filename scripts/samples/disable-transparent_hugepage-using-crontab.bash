#!/bin/bash
crontab -l | { cat; echo "@reboot sh /usr/local/sbin/ambari-thp-disable.sh"; } | crontab -
