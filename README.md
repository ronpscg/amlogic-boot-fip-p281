# amlogic-boot-fip for the AMLogic p281 board (s905w - a slimmed down s905x)

## About
The repo is a derived work of  https://github.com/LibreELEC/amlogic-boot-fip, using *lepotato* as *p281* and cleaning up the rest, to take much less space.
**It's objective is to boot mainline U-Boot, rather than keeping the default 2015 version that comes with those boxes**.

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


The target will then be able to run U-Boot. This is meant for a target with erased mmc blocks (first 4MB, and boot0 boot1 "hardware partitions").
There is documentation for achiveing it over the internet and The PSCG's training with this set of boards, and I will not continue writing on it in this file.

## More documentation from the derived project README.md file
```
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
