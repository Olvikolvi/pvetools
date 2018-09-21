#!/bin/bash

vms=`grep 'ceph:' /etc/pve/nodes/*/qemu-server/* | egrep -v 'backup=0|unused' | awk -F'/' '{print $7}' | sed 's/\..*//' | uniq`
for vm in $vms
do
 STATUS=$(qm status $vm)
 if [ "$STATUS" == "status: running"]; then
    ./snapANDback.sh $vm
 else
  echo "VM $vm $STATUS"
 fi
done
