	#!/bin/bash
set -e
POOL='pve'
VMID=$1
DATE=`date '+%Y%m%d%H%M%S'`
SNAPNAME="VM$DATE"
TMP="/mnt/tmpdisk/"

if [ ! -d $TMP ]; then
  echo "Target folder $TMP does not exists"
  exit
fi

if [ -z $VMID ]; then
 echo "ID puuttuu"
 exit
fi
if [ ! -f /etc/pve/qemu-server/$VMID.conf ]; then
  echo "You must run this on different server.."
  exit
fi

DISKS=`rbd -p pve ls|grep "vm-$VMID-disk"`
LATEST=''
for DISK in $DISKS
do
   # excl on vain kun virtuaalikone on käynnissä?
   LAST=`rbd -p pve ls -l | grep $DISK | egrep '@VM[0-9]{14}|excl' | tail -n 1 | awk '{print $1}'`
   echo "Found disk $LAST"
   LATEST+=" $LAST"
done

echo "Doing snapshot $SNAPNAME from $VMID"
qm snapshot $VMID $SNAPNAME

for TODISK in $LATEST
do
  TOSNAP=`sed 's/.*@//' <<< $TODISK`
  DISK=`sed 's/@.*//' <<< $TODISK`
  if [ "$TOSNAP" == "$DISK" ]; then
    FILENAME=$TMP$DISK"_INIT_"$SNAPNAME".rbd.iso.gz"
    ionice rbd -p $POOL export "$DISK" - | nice gzip -1 > $FILENAME
  else
    FILENAME=$TMP$DISK"_"$TOSNAP"_"$SNAPNAME".rbd.diff.gz"
    #from = vanhempi  #to = uudempi
    ionice rbd -p $POOL export-diff --from-snap "$TOSNAP" "$DISK" --snap "$SNAPNAME" - | nice gzip -1 > $FILENAME
  fi
  echo "Exported and gzipped from $DISK: $TOSNAP <> $SNAPNAME to file $FILENAME"
  echo "Uploading to sftp server.."
  ./upload.sh $FILENAME
  rm $FILENAME
  echo "done. Use ./list.sh to check"
done
