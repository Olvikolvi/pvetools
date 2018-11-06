if [ "$1" == "OLD" ]; then
 for m in `seq 1 8`; do
  for vmid in $(ls -1 /etc/pve/qemu-server/|grep conf|grep -v tmp| sed 's/[^0-9]*//g'); do
   ./rmsnaps.sh $vmid 20180$m
  done
 done
   ./rmsnaps.sh $vmid 20171
 exit
fi
DATE=`date  --date='-2 month' '+%Y%m'`
echo "Deleteing all snaphots older than $DATE"
#ei toimi poisto eri nodelta...
#for vmid in $(ls -1 /etc/pve/nodes/*/qemu-server/|grep conf|grep -v tmp| sed 's/[^0-9]*//g'); do
for vmid in $(ls -1 /etc/pve/qemu-server/|grep conf|grep -v tmp| sed 's/[^0-9]*//g'); do
 ./rmsnaps.sh $vmid $DATE
done
