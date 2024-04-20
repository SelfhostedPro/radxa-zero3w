#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
    case $RELEASE in
        trixie)
        ;;
        bookworm)
            fix_wifi_driver
        ;;
        stretch)
            fix_wifi_driver
        ;;
        buster)
            fix_wifi_driver
        ;;
        bullseye)
            fix_wifi_driver
        ;;
        bionic)
        ;;
        focal)
        ;;
    esac
} # Main

function fix_wifi_driver() {
    temp=$(mktemp)
    curl -L --output "$temp" "https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_$(curl -L https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/VERSION)_all.deb"
    dpkg -i "$temp"
    rm -f "$temp"
    source /etc/os-release
	tee /etc/apt/sources.list.d/radxa.list <<<"deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://radxa-repo.github.io/$RELEASE/ $VERSION_CODENAME main"
	apt update
	apt list --upgradable
	apt install -y radxa-firmware
	dpkg -i --force-overwrite /var/cache/apt/archives/radxa-firmware_0.2.21_all.deb
    apt --fix-broken install
}

# function add_wifi_creds() {
#     echo "Writing ${SDCARD}/etc/wpa_supplicant/wpa_supplicant.conf"
#     echo ${SUPPLICANT_CONTENT}
#     echo ${SUPPLICANT_CONTENT} > ${SDCARD}/etc/wpa_supplicant/wpa_supplicant.conf
    
#     echo "Writing ${SDCARD}/etc/network/interfaces"
#     echo ${INTERFACE_CONTENT}
#     echo ${INTERFACE_CONTENT} | tee -a ${SDCARD}/etc/network/interfaces
# }

Main "$@"
