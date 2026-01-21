# amlogic-boot-fip for the AMLogic p281 board (s905w - a slimmed down s905x)

## About
The repo is a derived work of  https://github.com/LibreELEC/amlogic-boot-fip, using *lepotato* as *p281* and cleaning up the rest, to take much less space.
**Its objective is to boot mainline U-Boot, rather than keeping the default 2015 version that comes with those boxes**.

Related Videos:
- [AMLogic: U-Boot replacement: Android vendor bootchain and modernized FIP creation scripts explained](https://www.youtube.com/watch?v=Ib4Rap7a2yw&list=PLBaH8x4hthVysdRTOlg2_8hL6CWCnN5l-&index=126)
- [AMLogic: Replacing the boot chain on s905w/s905x devices with mainline U-boot and Linux (6.19)](https://www.youtube.com/watch?v=E4isBhoqOTQ&list=PLBaH8x4hthVysdRTOlg2_8hL6CWCnN5l-&index=125)
- [AMLogic: eMMC boot partitions wreaking havoc and recovering where hardware is fine but hope is lost](https://www.youtube.com/watch?v=5K7ZHF8bxq4&list=PLBaH8x4hthVysdRTOlg2_8hL6CWCnN5l-&index=124)
- PscgBuildOS videos that use the AMLogic BSP, which runs this script, in addition to other things.

The p281  is essentially a *p212*. However, using the amlogic script with this chip results in an unrecongized revision 0xa (or something like this), which the lepotato variant does work with, albeit
with some BIT failures, that might have been also in the original ROM image. It's not an issue. It is important though to not allow Linux to overclock, as the frequency of this chipset is 1.2Ghz, and not 1.5Ghz.
The PscgBuildOS example gives and example of how to take care of that.

So the build uses:
- U-Boot: p212 - as the defconfig 
- Kernel: the respecive p281 defconfig (which lacks leds, for example, so perhaps a derived config)
- These prebuilts ATF images in this repository.

## Building and flashing
To build, (change variables with your paths)
```bash
: ${outdir=stam}
: ${in_uboot_bin=/home/ron/PscgBuildOS/out-amlogic/build/target/product/pscg_busyboxos/build-arm64/u-boot/u-boot-install/u-boot.bin}
mkdir -p $outdir
./build-fip.sh p281 $in_uboot_bin  $outdir
```

To flash to an sdcard:
```bash
./copy-to-media.sh sd
```

The target will then be able to run U-Boot - and assure that we boot from the sdcard. But U-Boot versions are very different, and we want to modernize everything, and run mainline U-Boot.
So booting it requires some thought and extra steps.
On existing (very old...) hardware and its boot chain you could press a button in most devices, and assure that *SARADC* in *U-Boot*
recognizes the sequence - making it try and load some things from some places, for example, the *U-Boot* boots scripts from the sdcard.

This is meant for a target with erased mmc blocks (first 4MB, and boot0 boot1 "hardware partitions"). 
There is documentation for achieving it over the internet and The PSCG's training with this set of boards, and I will not continue writing too much about in this documentation file. I did upload 3 videos
that explain it very well:
- [AMLogic: U-Boot replacement: Android vendor bootchain and modernized FIP creation scripts explained](https://www.youtube.com/watch?v=Ib4Rap7a2yw&list=PLBaH8x4hthVysdRTOlg2_8hL6CWCnN5l-&index=126)
- [AMLogic: Replacing the boot chain on s905w/s905x devices with mainline U-boot and Linux (6.19)](https://www.youtube.com/watch?v=E4isBhoqOTQ&list=PLBaH8x4hthVysdRTOlg2_8hL6CWCnN5l-&index=125)
- [AMLogic: eMMC boot partitions wreaking havoc and recovering where hardware is fine but hope is lost](https://www.youtube.com/watch?v=5K7ZHF8bxq4&list=PLBaH8x4hthVysdRTOlg2_8hL6CWCnN5l-&index=124)
This can be done in several ways, and generally it is not advised to do it, but on the other hand, it is not recommended to replace U-Boot and the ATF in the first place, if you want to use a device
the way the manufacturer, or whoever in its supply chain intended you to use it.

There are multiple ways to do wipe the respective eMMC areas, from Linux, U-Boot, and with USB commands. 
Detailed examples are below. The important thing for all - **Pay attention to your actual device enumeration**.

### eMMC erasing examples from U-Boot
This is all in *U-Boot*, and we are looking at an *AMLogic* *p281* board, so imagine you have  `gxl_p281_v1# ` prompt in U-Boot, before each line of this copy-pastable snippet:
```
#
# Note: mmc 0 is sdcard, mmc 1 is emmc
#
# Prepare some memory to work with - loadaddr is supposed to be defined and workable so just use it
addr=$loadaddr
mw.b $addr 0 0x800

# 
#  Note: mmc 1 1 is boot0
#
mmc dev 1 1
mmc write 0x1000000 0x1 0x4

# 
#  Note: mmc 1 2 is boot1
#
mmc dev 0 1
mmc write 0x1000000 0x1 0x4
```


An example from a real device, wiping ~2MiB
```
=> mmc dev 1
switch to partitions #0, OK
mmc1(part 0) is current device
=> mw.b $loadaddr  0x0 0x100000
=> 
=> 
=> 
=> mmc write $loadaddr 0x0 0x1000
MMC write: dev # 1, block # 0, count 4096 ... 4096 blocks written: OK
=> 
=> 
=> mmc dev 1 1
switch to partitions #1, OK
mmc1(part 1) is current device
=> mmc write $loadaddr 0x0 0x1000
MMC write: dev # 1, block # 0, count 4096 ... 4096 blocks written: OK
=> mmc dev 1 2
switch to partitions #2, OK
mmc1(part 2) is current device
=> mmc write $loadaddr 0x0 0x1000
MMC write: dev # 1, block # 0, count 4096 ... 4096 blocks written: OK
```

Then, if you have done well, upon resetting you will find something like the following output:
```
=> reset
resetting ...
bl31 reboot reason: 0xd
bl31 reboot reason: 0x0
system cmd  1.
GXL:BL1:9ac50e:bb16dc;FEAT:ADFC318C:0;POC:3;RCY:0;EMMC:0;READ:0;CHK:A7;READ:0;;
```

Then, you may want to insert your properly prepared (with these set of scripts) sdcard.


If you watched the respective video, you could see that the mmc device was actually mmc dev 2. Things can change, so again **Pay attention to your actual device enumeration**.

### eMMC erasing examples from Linux (demonstrated in the videos)

Below are examples that were covered in the videos.
( note: the Android BSP via its DTBs recognized mmcblk0 as the eMMC - usually it will be mmcblk1 (e.g. in U-boot) )

In this example we clear the following amount of information from the beginning of the device:
2MiB --> mmcblk0
2MiB --> mmcblk0boot0
3MiB --> mmcblk0boot1

What we did in in Android, Linux kernel 3.14 (in Linux the nodes are under /dev, not under /dev/block):
```
B=block/
dd if=/dev/zero of=/dev/$B/mmcblk0 bs=$((1024*1024)) count=2
dd if=/dev/zero of=/dev/$B/mmcblk0boot0 bs=$((1024*1024)) count=2
dd if=/dev/zero of=/dev/$B/mmcblk0boot1 bs=$((1024*1024)) count=3
```

We also showed that they on the provisioned device boot0 and boot1 are identical


For a more modern kernel (e.g. on another device where I already put Linux v6.19):
```
sysctl kernel.printk=1
uname -a
B=
N=1
dd if=/dev/zero of=/dev/$B/mmcblk${N} bs=512 count=2
dd if=/dev/zero of=/dev/$B/mmcblk${N}boot0 bs=$((1024*1024)) count=2
dd if=/dev/zero of=/dev/$B/mmcblk${N}boot1 bs=$((1024*1024)) count=3

# If the last two commands failed - disable write protection (The vendor Android versions did not come with that)
echo 0 > /sys/block/mmcblk${N}boot0/force_ro
echo 0 > /sys/block/mmcblk${N}boot1/force_ro
dd if=/dev/zero of=/dev/$B/mmcblk${N}boot0 bs=$((1024*1024)) count=2
dd if=/dev/zero of=/dev/$B/mmcblk${N}boot1 bs=$((1024*1024)) count=3
```




## More documentation from the derived project README.md file
System Requirements:
 - x86-64 Linux system
 - Python 3
 - sh
 - make
 - readlink
 - mktemp
 - cat
 - dd

Open-source tools exist to replace the binary-only Amlogic tools:
 - https://github.com/afaerber/meson-tools (GXBB, GXL & GXM only)
 - https://github.com/repk/gxlimg (GXBB, GXL, GXM & AXG only)
 - https://github.com/angerman/meson64-tools (developed for G12B, should work on G12A & SM1)
