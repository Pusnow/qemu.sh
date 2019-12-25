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

source config/user

QEMU_ARGS="-cpu host -machine q35 -smp $CORES -accel $ACCEL -m $MEMORY -monitor stdio -name \"$NAME\" -usb -device usb-tablet"
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
