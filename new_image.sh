#!/usr/bin/env bash
cd "$(dirname "$0")"
source config/user
qemu-img create -f qcow2 $DISK_PATH $DISK_SIZE
