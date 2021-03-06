#!/bin/bash
DSTPATH=$1
if [ -z "$DSTPATH" ]; then
  DSTPATH="ftp/ceph/"
fi
LSL=$2
if [ -z "$LSL" ]; then
  LSL="ls -latrh"
fi

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
send \"${LSL}\r\"
expect \"sftp>\"
send \"bye\r\"
expect \"#\"
"

