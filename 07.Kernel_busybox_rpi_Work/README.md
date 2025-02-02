# README: Booting Raspberry Pi 3B+ with Initramfs and U-Boot

## Prerequisites

### Ensure You Have a Properly Compiled Kernel and U-Boot

First, make sure your Linux kernel and U-Boot are compiled for AArch64 architecture, as Raspberry Pi 3B+ uses a 64-bit ARM processor.

- The compiled kernel image will be found under:
  ```sh
  /linux/arch/arm64/boot/Image
  ```
  This is the `Image` format kernel file.

- The zImage format kernel is used when compiled with the ARM toolchain but is **not** needed here.

## Preparing BusyBox with Static Linking

We need a statically linked `busybox` binary since it will be part of our initramfs:

```sh
make menuconfig
```
- Enable **static compilation option** under `BusyBox Settings → Build Options → Build BusyBox as a static binary (no shared libs)`

```sh
export CROSS_COMPILE=~/x-tools/aarch64-patrick-linux-gnu/bin/aarch64-patrick-linux-gnu-
make install
make -j12
```

## Understanding Initramfs

Initramfs (Initial RAM Filesystem) is a temporary root filesystem loaded into RAM at boot. It contains essential binaries and scripts required to initialize the system before mounting the real root filesystem.

- The Linux kernel unpacks the initramfs into RAM and uses it as the root filesystem.
- The initramfs is particularly useful in embedded systems where you don’t want a persistent root filesystem.

## Creating Initramfs Directory Structure

Go to your working directory:
```sh
cd EmbeddedLinuxKitchen
mkdir rootramfs
cd rootramfs
```

Copy essential binaries from BusyBox:
`/busybox/_install
Tree structure of `rootramfs`:
```sh
❯ tree
.
├── bin
│   ├── busybox
│   ├── cat
│   ├── ls
│   ├── mkdir
│   ├── mount
│   ├── rm
│   ├── rmdir
│   └── touch
├── sbin
│   └── ip
└── sh
```

## Understanding `cpio`

The `cpio` command is used to create an archive of the `rootramfs` directory:

```sh
find . | cpio -H newc -ov > rootramfs.cpio
```

### Explanation:
- `find .` → Lists all files inside `rootramfs`
- `cpio -H newc -ov > rootramfs.cpio`:
  - `-H newc` → Uses the **newc** format (modern portable cpio format)
  - `-o` → Creates an archive
  - `-v` → Verbose output
  - `> rootramfs.cpio` → Redirects output to the file `rootramfs.cpio`

Now your directory structure should look like:
```sh
❯ tree
.
├── bin
│   ├── busybox
│   ├── cat
│   ├── ls
│   ├── mkdir
│   ├── mount
│   ├── rm
│   ├── rmdir
│   └── touch
├── rootramfs.cpio
├── sbin
│   └── ip
└── sh
```

## Deploying `rootramfs.cpio` to the Boot Partition

Mount the SD card boot partition:
```sh
sudo mount /dev/mmcblk0p1 ~/sdcard/boot
```

Copy the initramfs file:
```sh
sudo cp ~/EmbeddedLinuxKitchen/rootramfs/rootramfs.cpio ~/sdcard/boot
```

## Configuring `extlinux.conf` for Bootflow Scan

Create `extlinux` directory and configuration file:
```sh
cd ~/sdcard/boot
mkdir extlinux
sudo touch extlinux.conf
sudo extlinux.conf
```

Add the following contents:
```ini
default hehOS_LocalBoot
timeout 10

menu title U-Boot Boot Menu
label hehOS_LocalBoot
kernel ../Image
fdt ../bcm2837-rpi-3-b-plus.dtb
INITRD ../rootramfs.cpio
append 8250.nr_uarts=1 console=ttyS0,115200n8 rdinit=sh
```

### Explanation:
- `default hehOS_LocalBoot` → Selects `hehOS_LocalBoot` as the default entry
- `timeout 10` → Waits 10 seconds before booting automatically
- `kernel ../Image` → Points to the kernel binary
- `fdt ../bcm2837-rpi-3-b-plus.dtb` → Loads the device tree for Raspberry Pi 3B+
- `INITRD ../rootramfs.cpio` → Specifies the initramfs file
- `append ...` → Kernel boot parameters:
  - `console=ttyS0,115200n8` → Configures UART for serial output
  - `rdinit=sh` → Directs the kernel to start `sh` as the first process

## Booting with Minicom

Connect to the Raspberry Pi via UART:
```sh
sudo minicom -D /dev/ttyUSB0
```

After autoboot, scan for boot configurations:
```sh
bootflow scan
```

## Testing

At this stage:
- The system is running completely in RAM.
- You **can remove the SD card**, and the system will continue functioning.

## Summary

1. Compile the kernel for AArch64.
2. Build a **statically linked** BusyBox.
3. Create an **initramfs** with required binaries.
4. Use `cpio` to package the `rootramfs`.
5. Copy `rootramfs.cpio` to the boot partition.
6. Configure `extlinux.conf` for U-Boot.
7. Boot using `minicom` and scan for bootflows.

Now you have a Raspberry Pi running entirely from RAM! 🎉


### Video Result

https://github.com/user-attachments/assets/70c65382-3b9a-4d40-94df-7b9ad7489c56
