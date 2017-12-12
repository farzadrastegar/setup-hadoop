#!/bin/bash

enabledfile="/sys/kernel/mm/transparent_hugepage/enabled"
defragfile="/sys/kernel/mm/transparent_hugepage/defrag"

if test -f ${enabledfile}; then
echo never > ${enabledfile}
fi
if test -f ${defragfile}; then
echo never > ${defragfile}
fi
