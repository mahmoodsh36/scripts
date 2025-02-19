#!/usr/bin/env sh

# ./install_nix.sh /dev/nvme0n1
# the script tries to clone my nixos, so needs internet, for now atleast (would need internet for packages anyway, unless we can get away with copying everything from one machine to another..)

USE_BOOT=true

drive="$1"

[ -z "$drive" ] && echo "usage: $0 <drive>" && exit
[ "$EUID" -ne 0 ] && echo "must be run as root" && exit

# make sure /mnt exists
mkdir /mnt 2>/dev/null

# incase there are leftovers from a previous run
umount /mnt/boot 2>/dev/null
umount /mnt/ 2>/dev/null
swapoff -a

# prepare the drive
# parted "$drive" mklabel gpt
sgdisk -Zg "$drive" # wipe partition table (gpt)
sgdisk -n 1:1MiB:2048MiB -t 1:EF00 -c 1:myboot "$drive" # boot (efi)
sgdisk -n 2:2096MiB:50GiB -t 2:8200 -c 2:myswap "$drive" # swap
sgdisk -n 0:0:0 -t 3:8300 -c 0:myroot "$drive" # root

# we need sync disk changes so we can use 'lsblk' or other tools below
partprobe "$drive" || sleep 2
udevadm settle

# label the partitions
boot_partition="$(lsblk -o NAME,PARTLABEL -p -r "$drive" | grep myboot | cut -d ' ' -f1)"
swap_partition="$(lsblk -o NAME,PARTLABEL -p -r "$drive" | grep myswap | cut -d ' ' -f1)"
root_partition="$(lsblk -o NAME,PARTLABEL -p -r "$drive" | grep myroot | cut -d ' ' -f1)"
lsblk -o NAME,PARTLABEL -p -r "$drive" 

# parted seems to fail to format the drives... dunno why
if [ "$USE_BOOT" = true ]; then
  mkfs.fat -F 32 "$boot_partition"
fi
mkswap "$swap_partition"
yes | mkfs.ext4 "$root_partition"

# mount the partitions
mount "$root_partition" /mnt || exit
mkdir /mnt/boot 2>/dev/null
if [ "$USE_BOOT" = true ]; then
  mount "$boot_partition" /mnt/boot || exit
else
  mount "$root_partition" /mnt/boot || exit
fi
swapon "$swap_partition"

# generate config (we need the hardware-configuration.nix file that is generated)
mkdir -p /mnt/etc/
cd /mnt/etc/
git clone https://github.com/mahmoodsh36/nixos
cp nixos/desktop.nix nixos/configuration.nix
rm nixos/hardware-configuration.nix
nixos-generate-config --root /mnt

# install nixos!
# nixos-install || exit 1
nixos-install --impure --flake /mnt/etc/nixos/flake.nix#mahmooz || exit 1

if [ -d /home/mahmooz/work ]; then
  sudo -u mahmooz rsync -Pa --exclude venv /home/mahmooz/work /mnt/home/mahmooz/
fi

umount /mnt/boot
umount /mnt/
