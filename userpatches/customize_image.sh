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
            dietpi_trixie
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

function dietpi_trixie() {
    echo "Installing DietPi!!!"
    sudo bash -c "G_DISTRO=8  G_DISTRO_NAME='trixie' HW_MODEL=90 G_RASPBIAN=0 GITOWNER='MichaIng' GITBRANCH='newimages' IMAGE_CREATOR='SelfhostedPro' PREIMAGE_INFO='Dietpi Armbian' WIFI_REQUIRED=1 DISTRO_TARGET=8; $(curl -sSfL 'https://raw.githubusercontent.com/MichaIng/DietPi/master/.build/images/dietpi-installer')"
}

function dietpi_bookworm() {
    G_DISTRO=7
    G_DISTRO_NAME='bookworm'
    HW_MODEL=90
    G_RASPBIAN=0
    GITOWNER='MichaIng'
    GITBRANCH='newimages'
    IMAGE_CREATOR='SelfhostedPro'
    PREIMAGE_INFO='Dietpi Armbian'
    WIFI_REQUIRED=1
    DISTRO_TARGET=7
}

function install_diet_pi() {
    
}

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

Main "$@"
