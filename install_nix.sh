#!/usr/bin/env sh

# ./install_nix.sh /dev/nvme0n1
# the script tries to clone my nixos, so needs internet, for now atleast
#
# if we're running as root why sudo?

drive="$1"

[ -z "$drive" ] && echo "usage: $0 <drive>" && exit
[ "$EUID" -ne 0 ] && echo "must be run as root" && exit

# make sure /mnt exists
sudo mkdir /mnt 2>/dev/null

# incase there are leftovers from a previous run
sudo umount /mnt/boot 2>/dev/null
sudo umount /mnt/ 2>/dev/null
swapoff -a

# prepare the drive
parted "$drive" mklabel gpt
parted -s -a opt "$drive" mkpart myboot fat32 1MiB 512MiB
parted -s -a opt "$drive" set 1 boot on
parted -s -a opt "$drive" mkpart myswap ext4 512MiB 50GiB
parted -s -a opt "$drive" mkpart myroot ext4 50GiB 100%

boot_partition="/dev/$(lsblk -l "$drive" | awk 'NR==3 {print $1}')"
swap_partition="/dev/$(lsblk -l "$drive" | awk 'NR==4 {print $1}')"
root_partition="/dev/$(lsblk -l "$drive" | awk 'NR==5 {print $1}')"

# parted seems to fail to format the drives... dunno why
mkfs.fat -F 32 "$boot_partition"
mkswap "$swap_partition"
yes | mkfs.ext4 "$root_partition"

# mount the partitions
mount "$root_partition" /mnt || exit
mkdir /mnt/boot 2>/dev/null
mount "$boot_partition" /mnt/boot || exit
swapon "$swap_partition"

# generate config (we need the hardware-configuration.nix file that is generated)
mkdir -p /mnt/etc/
cd /mnt/etc/
git clone https://github.com/mahmoodsh36/nixos
cp nixos/desktop.nix nixos/configuration.nix
#rm nixos/hardware-configuration.nix
nixos-generate-config --root /mnt

# install nixos!
# nixos-install || exit 1
nixos-install --impure --flake /mnt/etc/nixos/flake.nix#mahmooz || exit 1

# why does this not work?
if [ -d /home/mahmooz/work ]; then
  echo here1
  mkdir -p /mnt/home/mahmooz/
  chown mahmooz:mahmooz /mnt/home/mahmooz
  echo here2
  rsync -Pa --exclude 'venv' /home/mahmooz/work /mnt/home/mahmooz/
  find /mnt/home/mahmooz/work -exec chown mahmooz:users {} \;
fi

sudo umount /mnt/boot
sudo umount /mnt/