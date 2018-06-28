#!/bin/bash
FILE="$1"
DST="$2"
SRCPATH="ftp/ceph/"
HOST="doopbu01.doop.fi"
USER="doop01"
PASS="TigvaucDedic"
FILEBN=`basename $FILE`
TEST="$FILE $DST"

expect -c "
set timeout -1
spawn sftp ${USER}@${HOST}
expect \"password: \"
send \"${PASS}\r\"
expect \"sftp>\"
send \"cd ${SRCPATH}\r\"
expect \"sftp>\"
send \"get ${TEST}\r\"
expect \"sftp>\"
send \"bye\r\"
expect \"#\"
"


