#!/bin/bash
NEWID=$1
if [ -z $NEWID ]; then
  NEWID=$(expr $(cat /etc/pve/.vmlist|grep node|sort -n|tail -n1|awk '{print $1}'| tr -dc '0-9') + 1)
fi
if grep \"$NEWID\" /etc/pve/.vmlist; then 
  echo "Virtuaalikone ID:llä $NEWID on jo olemassa"
else 
  qm create $NEWID --name cos$NEWID.doop.fi --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1,tag=100 --net2 virtio,bridge=vmbr2 --virtio0 ceph:20,format=raw --bootdisk virtio0 --ostype l26 --memory 4096 --onboot no --sockets 2
fi
echo "Oletko aivan varma, että haluat tuhota KAIKKI levyn pve/vm-$NEWID-disk-1 sisällön? [sure]"
read varmistus
if [ "$varmistus" == "sure" ]; then
 qm stop $NEWID -timeout 10
 ct --files-dir=/etc/ceph < ignition.yml > ignition.json
 rbd feature disable pve/vm-$NEWID-disk-1 object-map fast-diff deep-flatten #features unsupported by the kernel
 RBD_DEV=$(rbd map pve/vm-$NEWID-disk-1)
 ./init/bin/coreos-install -d $RBD_DEV -i ignition.json -C stable
 rbd unmap $RBD_DEV
 echo "Now starting $NEWID"
 qm start $NEWID
fi
