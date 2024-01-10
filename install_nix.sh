#!/usr/bin/env sh

# ./install_nix.sh /dev/nvme0n1
# the script tries to clone my nixos, so needs internet, for now atleast

drive="$1"

[ -z "$drive" ] && echo "usage: $0 <drive>" && exit
[ "$EUID" -ne 0 ] && echo "must be run as root" && exit

# make sure /mnt exists
sudo mkdir /mnt 2>/dev/null

# incase there are leftovers from a previous run
sudo umount /mnt/boot 2>/dev/null
sudo umount /mnt/ 2>/dev/null

# prepare the drive
parted "$drive" mklabel gpt
parted -s -a opt "$drive" mkpart primary fat32 1MiB 261MiB
parted -s -a opt "$drive" set 1 boot on
parted -s -a opt "$drive" mkpart primary ext4 261MiB 100%
# parted -s -a opt "$drive" mkpart primary root ext4 261MiB 100%

boot_partition="/dev/$(lsblk -l "$drive" | awk 'NR==3 {print $1}')"
root_partition="/dev/$(lsblk -l "$drive" | awk 'NR==4 {print $1}')"
echo $boot_partition
echo $root_partition

# parted seems to fail to format the drives... dunno why
mkfs.fat -F 32 "$boot_partition"
mkfs.ext4 "$root_partition"

# mount the partitions
mount "$root_partition" /mnt || exit
mkdir /mnt/boot 2>/dev/null
mount "$boot_partition" /mnt/boot || exit

# nobody needs swap
swapoff -L label

# generate config (we need the hardware-configuration.nix file that is generated)
mkdir -p /mnt/etc/
cd /mnt/etc/
git clone https://github.com/mahmoodsheikh36/nixos
#rm nixos/hardware-configuration.nix
nixos-generate-config --root /mnt

# install nixos!
nixos-install

sudo umount /mnt/boot
sudo umount /mnt/