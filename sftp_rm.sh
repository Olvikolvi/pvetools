#!/bin/bash
FILE="$1"
SRCPATH="ftp/ceph/"
HOST="doopbu01.doop.fi"
USER="doop01"
PASS="TigvaucDedic"
FILEBN=`basename $FILE`

expect -c "
set timeout -1
spawn sftp ${USER}@${HOST}
expect \"password: \"
send \"${PASS}\r\"
expect \"sftp>\"
send \"cd ${SRCPATH}\r\"
expect \"sftp>\"
send \"rm ${FILEBN}\r\"
expect \"sftp>\"
send \"bye\r\"
expect \"#\"
"


