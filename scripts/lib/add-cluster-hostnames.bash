#!/bin/bash
cat << 'EOF' >> /etc/hosts

10.1.228.112 master1.rotbenegar-bk.ir
10.1.228.113 master2.rotbenegar-bk.ir
10.1.228.114 slave1.rotbenegar-bk.ir
10.1.228.115 slave2.rotbenegar-bk.ir
10.1.228.116 slave3.rotbenegar-bk.ir
10.1.228.24 master1.hadoopcluster.webranking
10.1.228.22 pxe-server.rotbenegar-bk.ir
EOF
