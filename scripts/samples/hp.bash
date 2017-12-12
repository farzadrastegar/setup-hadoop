#!/bin/bash
enabledfile="/sys/kernel/mm/transparent_hugepage/enabled"
defragfile="/sys/kernel/mm/transparent_hugepage/defrag"

echo never > ${enabledfile}
echo never > ${defragfile}

