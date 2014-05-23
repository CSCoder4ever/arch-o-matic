#!/bin/bash

SDA1=/dev/sda1
SDA=/dev/sda
MNT=/mnt
FSTAB=/etc/fstab
PACMAN_MIRROR=/etc/pacman.d/mirrorlist
HOSTNAME=/etc/hostname
ZONE=/usr/share/zoneinfo/America/Los_Angeles
LOCAL_TIME=/etc/localtime
LOCALE_GEN=/etc/locale.gen
LOCALE_CONF=/etc/locale.conf
MKINITCPIO_CONF=/etc/mkinitcpio.conf
GRUB_CFG=/boot/grub/grub.cfg
BASH=/bin/bash
SUDOERS=/etc/sudoers
CREATOR="CSCoder4ever"
USB_MOUNT_POINT=/root/usb/
GIT_CLONED_DIR=arch-o-matic

# This script is made to automate the installation of Arch onto my server.
# it assumes the disk you want to use is /dev/sda1

# To get this script going in an Arch live CD, do the following:
# mkdir usb && mount /dev/sdb1 usb
# this of course assumes the usb is /dev/sdb1
# to verify, the command "df -h" will come in handy.

echo "Welcome to $CREATOR's installation script! part 1 of 2"

echo "The Following will remove ALL data from $SDA1"
read -p "continue? y/n: " YesOrNo # asks if you'd like to format the drive

if [ "$YesOrNo" = "y" ]; then  # If yes, format here we come!
	#echo "Formatting  $SDA1 to ext4" 
	mkfs -t ext4 $SDA1 # mkfs.ext4 $SDA1
	#echo "Format complete!"
else #if no, program will exit.
	read -p "exit? y/n: " exitR
	if [ "$exitR" = "y" ]; then
	exit
	fi
fi

sleep 1 && read -p "do you have wifi for the installation? y/n: " wifiResponse
if [ "$wifiResponse" = "y" ]; then
	wifi-menu
else
	echo "assuming you're connected via ethernet"
fi

sleep 1 && echo "Mounting $SDA1"
	mount $SDA1 $MNT

sleep 1 && read -p "Which editor would you like to use? " USER_EDITOR

sleep 1 && read -p "Want to edit $PACMAN_MIRROR? y/n: " pacResponse
if [ "$pacResponse" = "y" ]; then
	$USER_EDITOR $PACMAN_MIRROR
fi

sleep 1 && echo "installing base system"
	pacstrap $MNT base base-devel grub-bios sudo

sleep 1 && echo "Generating fstab"
	genfstab -p $MNT >> $MNT$FSTAB

sleep 1 && echo "edit $HOSTNAME"
	$USER_EDITOR $MNT$HOSTNAME

sleep 1 && echo "creating a symlink for $ZONE to $LOCAL_TIME"
	ln -s $MNT$ZONE $MNT$LOCAL_TIME

sleep 1 && echo "uncomment a section in $LOCALE_GEN"
	$USER_EDITOR $MNT$LOCALE_GEN

sleep 1 && read -p "Would you like to edit $MKINITCPIO_CONF? y/n: " mkResponse
if [ "$mkResponse" = "y" ]; then
	$USER_EDITOR $MNT$MKINITCPIO_CONF
fi

echo "uncomment the section that contains \"wheel\" to give $userName admin rights." && sleep 5 && $USER_EDITOR $MNT$SUDOERS

sleep 1 && echo "copying part 2 of install script"
	#cd $USB_MOUNT_POINT && cp archInstallScriptPart2.sh $MNT/etc/part2.sh &&\
	cd $GIT_CLONED_DIR && cp archInstallScriptPart2.sh $MNT/etc/part2.sh &&\
	chmod +x $MNT/etc/part2.sh && ln -s $MNT/etc/part2.sh $MNT/usr/bin/parttwo

sleep 1 && echo "arch-chrooting into the new install, type in \"parttwo\" to get part 2 going."
	arch-chroot $MNT

