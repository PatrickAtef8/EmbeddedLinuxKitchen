
# Booting the Kernel Using QEMU After U-Boot

## NOTE: Kernel Boot Failures
The kernel will **panic** if:
1. No arguments are passed to the kernel.
2. No root filesystem is found (VFS error).
3. The init process is missing or terminates immediately (e.g., `printf("Hello Kernel");`).

---

## 1. Compiling the Kernel

### Clone and Checkout the Kernel Repository
```sh
git clone git@github.com:raspberrypi/linux.git
```
This command clones the Linux kernel repository for Raspberry Pi from the specified source.

```sh
git checkout rpi-6.6.y 
```
This command checks out on this branch 

### Configure and Compile the Kernel
```sh
make menuconfig
```
This command opens the kernel configuration menu, allowing customization of kernel features. you may not need to change any configurations 

```sh
export CROSS_COMPILE=~/x-tools/arm-patrick-linux-musleabihf/bin/arm-patrick-linux-musleabihf-
```
This command sets the cross-compiler path for building the kernel for ARM architecture.

```sh
export ARCH=arm
```
This command specifies that the kernel is being compiled for the ARM architecture.

```sh
make -j12
```
This command compiles the kernel using 12 parallel jobs for faster compilation.

### Kernel Output
After compilation, the kernel and device tree will be located at:
- `linux/arch/arm/boot/zImage` (Kernel Image)
- `linux/arch/arm/boot/dts/vexpress-v2p-ca9.dtb` (Device Tree Blob)

---

## 2. Preparing the Root Filesystem with BusyBox


Now because we dont have init process, we can easily make init.c with printf("Hello Kernel");
but we need our distro to be useful and has a meaning so we will use busybox to achieve this goal 
busybox is a github repo that has most of the root file system applications or commands like (ls,cat,mount,...)

### Clone and Compile BusyBox
```sh
git clone git@github.com:mirror/busybox.git
```
This command clones the BusyBox repository.

```sh
git checkout 1_36_1
```
This command checks out the latest available BusyBox tag.

```sh
make menuconfig
```
This command opens the BusyBox configuration menu to select utilities required in the root filesystem (select your wanted commands).

### Compile BusyBox
```sh
export CROSS_COMPILE=~/x-tools/arm-patrick-linux-musleabihf/bin/arm-patrick-linux-musleabihf-
```
This command sets the cross-compiler path for compiling BusyBox.

```sh
make install
```
This command installs BusyBox utilities into the `_install/` directory.

```sh
make -j12
```
This command compiles BusyBox using 12 parallel jobs.

---

## 3. Preparing the SD Card Image
Ensure `sd.img` has two partitions:
- `loop16p1` → Mounted to `boot/`
- `loop16p2` → Mounted to `rootfs/`

**Check 02.U-boot_Qemu_Work**

### Copy Required Files
Since BusyBox is dynamically linked(I didn't use -static while compiling), include shared libraries under sysroot of the toolchain and copy them in rootfs:
```sh
cp -r _install/* /sdcard/rootfs
cp -r ~/x-tools/arm-patrick-linux-musleabihf/arm-patrick-linux-musleabihf/sysroot/lib ~/sdcard/rootfs
cp -r ~/x-tools/arm-patrick-linux-musleabihf/arm-patrick-linux-musleabihf/sysroot/usr ~/sdcard/rootfs
```
```sh
cp ~/EmbeddedLinuxKitchen/linux/arch/arm/boot/zImage /sdcard/boot
```
This command copies the kernel image to the boot partition.

### Expected Directory Structure
#### `rootfs/`
```
├── bin --> from busybox
├── lib --> under sysroot
├── sbin --> from busybox
└── usr 
    ├── bin --> from busybox
    ├── lib --> under sysroot
    └── sbin --> from busybox
```
#### `boot/`
```
├── uboot.env
├── vexpress-v2p-ca9.dtb --> under linux/arch/arm/boot/
└── zImage --> under linux/arch/arm/boot/
```

---

## 4. Booting the Kernel
### Method 1: U-Boot Commands
```sh
setenv bootargs "console=ttyAMA0 init=/bin/sh root=/dev/mmcblk0p2"
```
This command sets kernel boot arguments to specify the console device, init process, and root filesystem.

```sh
fatload mmc 0:1 $kernel_addr_r zImage
```
This command loads the kernel image from the first partition into RAM.

```sh
fatload mmc 0:1 $fdt_addr_r vexpress-v2p-ca9.dtb
```
This command loads the device tree blob into RAM.

```sh
bootz $kernel_addr_r - $fdt_addr_r
```
This command boots the kernel with the provided device tree.

### Method 2: Bootflow Scan (Recommended)
Create `boot/extlinux/extlinux.conf`:
```
DEFAULT linux
LABEL linux
LINUX ../zImage
FDT ../vexpress-v2p-ca9.dtb
APPEND console=ttyAMA0 init=/bin/sh root=/dev/mmcblk0p2
```
This configuration file specifies the kernel, device tree, and boot arguments for bootflow scan.

Final `boot/` structure:
```
.
├── extlinux
│   └── extlinux.conf
├── uboot.env
├── vexpress-v2p-ca9.dtb
└── zImage
```

---

## 5. Running QEMU
```sh
qemu-system-arm -M vexpress-a9 -kernel u-boot/u-boot -nographic -sd ../sdcard/sd.img
```
This command starts QEMU emulating the ARM Versatile Express platform, running U-Boot as the firmware.

After autoboot, run:
```sh
bootflow scan
```
This command automatically detects the boot configuration and boots the kernel and as the init process is shell(init=/bin/sh) so kernel will not panic.

---
## 6. Results

- Example of kernel panic because of init ( here I tried not to add the shared libraries under sysroot)

![Result1](Results/before_adding_sysroot.png)

- After adding libraries under sysroot you are now on your shell 

![Result2](Results/after_adding_sysroot.png)

 - Testing Commands added form busybox

![Result3](Results/testing_added_commands.png)
---