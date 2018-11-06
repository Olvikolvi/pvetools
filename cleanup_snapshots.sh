DATE=`date  --date='-3 month' '+%Y%m'`
echo "Deleteing all snaphots older than $DATE"
#ei toimi poisto eri nodelta...
#for vmid in $(ls -1 /etc/pve/nodes/*/qemu-server/|grep conf|grep -v tmp| sed 's/[^0-9]*//g'); do
for vmid in $(ls -1 /etc/pve/qemu-server/|grep conf|grep -v tmp| sed 's/[^0-9]*//g'); do
 echo "./rmsnaps.sh $vmid $DATE"
done
