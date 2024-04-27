



# losetup -f # Find loopback devices
# mount -v 
loopback_dev="$(losetup -f)"

# Where we can start wrighting data
partition_start=16
# Size of boot partition in mb
boot_size=128
# Size of image to create
base_image_size=$((partition_start+boot_size+1136))

image_name="radxa_zero3_custom"

current_dir="$PWD"

errexit () {
	findmnt -M "${current_dir}/core" &> /dev/null && umount -R "${current_dir}/core"
	[[ -e $loopback_dev ]] && losetup "$loopback_dev" &> /dev/null && losetup -d "$loopback_dev"
	[[ -f $image_name.img ]] && rm "$image_name.img"
}

init () {
    # Create Base Directories and Devices for bootstraping
    mkdir -p core/boot

    # Create blank .img of the correct size
    fallocate -x -l "${base_image_size}M" radxa_zero3_custom.img

    # Create GPT
    parted -s "${image_name}.img" mklabel gpt

    # Create Boot Partition
    parted -s "${image_name}.img" unit MiB mkpart 'BOOT' fat32 $partition_start $((partition_start+boot_size))

    # Create Root Partition
    parted -s "${image_name}.img" unit MiB mkpart 'root' ext4 $((partition_start+boot_size)) 100%

    [[ -e $loopback_dev ]] || mknod /dev/loop0 b 7 0 # Create loop0

    echo "Mounting image ${image_name} to loopback ${loopback_dev}"
    losetup -P "$loopback_dev" "$image_name.img"
    partprobe "$loopback_dev"
    partx -u "$loopback_dev"

    # Make boot partition FAT32
    mkfs.fat -F 32 -S 512 -s "$boot_size" "${loopback_dev}p1"

    # Make root partition ext4
    mkfs.ext4 -e "${loopback_dev}p2"
    echo "Filesystem Setup"
}

debootstrap () {
    distro="trixie"
    packages='apt,bash-completion,bzip2,ca-certificates,cron,curl,fdisk,gnupg,htop,iputils-ping,locales,nano,p7zip,parted,procps,psmisc,sudo,systemd-sysv,tzdata,udev,unzip,wget,whiptail,'
    debootstrap --variant=minbase --include="$packages" --arch="aarch64" --keyring="$keyring" "$distro"
}

while getopts ":ci" opt; do
  case ${opt} in
    i ) 
        echo "Initializing Filesystem"
        init
      ;;
    c ) 
        echo "Cleaning up"
        errexit
      ;;
    clean ) 
        echo "Cleaning up"
        errexit
      ;;
    \? ) echo "Usage: cmd [-h] [-c]"
      ;;
  esac
done
# debootstrap