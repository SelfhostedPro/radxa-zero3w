FROM debian:trixie
RUN apt update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt install -y \
        git \
        systemd-container \
        zerofree \
        parted \
        debootstrap \
        mmdebstrap \
        dbus \
        xz-utils \
        qemu-user-static \
        binfmt-support \
        dosfstools \
        udev \
        fdisk \
        kpartx
        
