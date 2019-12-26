#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ "$#" -eq 0 ]; then
    echo "Loading config/user"
    source config/user
elif [ "$#" -eq 1 ]; then
    echo "Loading $1"
    source $1 || exit 1
else
    echo "Illegal number of parameters."
    exit 1
fi

echo "system_powerdown" | socat - UNIX-CONNECT:${MONITOR}
