#!/bin/bash
DSTPATH="ftp/ceph/"
HOST="doopbu01.doop.fi"
USER="doop01"
PASS="TigvaucDedic"

expect -c "
spawn sftp ${USER}@${HOST}
expect \"password: \"
send \"${PASS}\r\"
expect \"sftp>\"
send \"cd ${DSTPATH}\r\"
expect \"sftp>\"
send \"ls -latrh\r\"
expect \"sftp>\"
send \"bye\r\"
expect \"#\"
"


