#!/usr/bin/env bash
cd "$(dirname "$0")"

source config/common
unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) source config/linux ;;
Darwin*) source config/mac ;;
*)
    echo "Unsupported machine: $unameOut"
    exit 1
    ;;
esac

if [ "$#" -eq 0 ]; then
    echo "Loading config/user"
    source config/user
elif [ "$#" -eq 1 ]; then
    echo "Loading $1"
    source $1 || echo "Not found: $1" && exit 1
else
    echo "Illegal number of parameters."
    exit 1
fi

QEMU_ARGS="-machine q35,accel=$ACCEL -smp $CORES -accel $ACCEL -m $MEMORY -monitor stdio -name \"$NAME\""
QEMU_ARGS="$QEMU_ARGS -device virtio-tablet-pci"
QEMU_ARGS="$QEMU_ARGS -device virtio-keyboard-pci"
QEMU_ARGS="$QEMU_ARGS -device virtio-balloon-pci"
QEMU_ARGS="$QEMU_ARGS -device virtio-vga"
QEMU_ARGS="$QEMU_ARGS -drive file=$DISK_PATH,if=virtio,cache=writeback,cache.direct=on$DISK_OPT,format=qcow2"

case "${NETWORKING}" in
user*)
    HOST_FORWARD=""
    for host_port in "${!PORT_FORWARDING[@]}"; do
        guest_port="${PORT_FORWARDING[$host_port]}"
        HOST_FORWARD="$HOST_FORWARD,hostfwd=tcp:0.0.0.0:$host_port-:$guest_port,hostfwd=udp:0.0.0.0:$host_port-:$guest_port"
    done
    QEMU_ARGS="$QEMU_ARGS -nic user,model=virtio-net-pci$HOST_FORWARD"
    ;;
*)
    echo "Unsupported networking: $NETWORKING"
    exit 1
    ;;
esac

if [[ $INSTALL_ISO ]]; then
    QEMU_ARGS="$QEMU_ARGS -drive file=$INSTALL_ISO,media=cdrom"
fi

if [[ $DRIVER_ISO ]]; then
    QEMU_ARGS="$QEMU_ARGS -drive file=$DRIVER_ISO,media=cdrom"
fi
echo $QEMU_ARGS
$QEMU $QEMU_ARGS
