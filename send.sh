#!/bin/bash
user="$(whoami)"
SOCK="/tmp/$user/nw-notify.sock"
if [[ ! -e $SOCK ]];then
    echo "Server socket at $SOCK not found. Start server with volbrid(1)"
    exit 12
fi
echo $@|socat - "UNIX-CONNECT:$SOCK"
