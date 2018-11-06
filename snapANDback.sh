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

IFS=" " read tmpsize tmpmount <<< $(df --output="avail,target" $TMP |tail -n1)
if [ "$tmpmount" == '/' ]; then
  read -p "$TMP is mounted to root fs. Are you sure you want to continue? [N/y]: " jatko
  if [ "$jatko" != "y" ]; then
    echo "ok, wont continue";
    exit
  fi
fi

if [ "$tmpsize" -lt "20000000" ]; then
  read -p "$TMP is too small ($tmpsize bytes). Are you sure you want to continue? [N/y]: " jatko
  if [ "$jatko" != "y" ]; then
    echo "ok, wont continue";
    exit
  fi
fi

if [ -z $VMID ]; then
 echo "ID puuttuu"
 exit
fi
if [ ! -f /etc/pve/qemu-server/$VMID.conf ]; then
  echo "You must run this on different server.."
  exit
fi

DISKS=`rbd -p $POOL ls|grep "vm-$VMID-disk"`
LATEST=''
for DISK in $DISKS
do
   # excl on vain kun virtuaalikone on käynnissä?
   LAST=`rbd -p $POOL ls -l | grep $DISK | egrep '@VM[0-9]{14}|excl' | tail -n 1 | awk '{print $1}'`
   echo "Found disk $LAST"
   LATEST+=" $LAST"
done

echo "Doing snapshot $SNAPNAME from $VMID"
qm snapshot $VMID $SNAPNAME

for TODISK in $LATEST
do
  TOSNAP=`sed 's/.*@//' <<< $TODISK`
  DISK=`sed 's/@.*//' <<< $TODISK`

  LAST_INIT=`./list.sh | grep "${DISK}_INIT_" | egrep -o 'INIT_VM([0-9]{14})' | sed 's/[^0-9]*//g' | tail -n1`

  if [ "$TOSNAP" == "$DISK" ] || [ $DATE -gt $(($LAST_INIT+100000000)) ]; then
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
