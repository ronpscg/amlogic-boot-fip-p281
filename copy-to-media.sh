#!/bin/bash

# Copy to sdcard first. 
: ${DEV=""}
: ${indir=stam}


if [ -z "$DEV" ] ; then
	echo "Please specify the environment variable DEV. We will not do it for you as you need to be SUPER CAREFUL in what you are doing to not overwrite possibly important data"
	exit 1
fi

SUDO=sudo
case "$1" in 
	sd)
		# Works just as well when flashing to the emmc.		
		infile=u-boot.bin.sd.bin
		;;
	emmc)
		infile=u-boot.bin # so far unused
		;;
	usb)
		echo "usb does not mean what you think and there  are other places to read about it"
		;;
	*)
		echo "Wrong usage, please provide a parameter in \$1"
		exit 1
esac

if [ ! -b "$DEV" -a ! "$2" = "file"  ] ; then
	echo "$DEV is not a block device"
	echo "Did you mean to copy to a file? If so, be specific and run $0 $1 file"
	exit 1
elif [ ! -e "$DEV" ] ; then
		echo "$DEV does not exist"
		exit 1
fi

if [ "$2" = "file" ] ; then
	SUDO=""
fi

$SUDO dd if=$indir/$infile of=$DEV skip=1 seek=1 bs=512 conv=notrunc && $SUDO dd if=$indir/$infile of=$DEV count=444 bs=1 conv=notrunc && sync
