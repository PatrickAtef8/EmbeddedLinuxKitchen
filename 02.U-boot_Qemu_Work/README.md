# U-Boot Setup and SD Card Preparation

This README provides a step-by-step guide to prepare an SD card image, configure U-Boot, and test it using QEMU. Each command is explained for clarity.

---

## Prerequisites
- **Host System**: Linux-based OS with necessary tools installed (`dd`, `losetup`, `mkfs`, etc.).
- **Toolchain**: ARM GCC toolchain for cross-compilation.
- **QEMU**: Emulator to test U-Boot.

---

## Step 1: Prepare the SD Card Image
### 1. Create the `sdcard` directory
```bash
mkdir sdcard
```
This creates a directory to work with the SD card files.

### 2. Create an empty SD image file
```bash
touch sdcard/sd.img
```
This creates an empty image file to act as our SD card.

### 3. Allocate 1GB raw memory for the SD card
```bash
dd if=/dev/zero of=sdcard/sd.img bs=1M count=1024
```
Fills the `sd.img` file with 1GB of zero characters (`^@`).

### 4. Partition the SD card
```bash
cfdisk sdcard/sd.img
```
- Select **DOS** partition table.
- Create:
  - **200MB Primary Partition** (set as bootable, type FAT16).
  - **Extended Partition** for the remaining space (type EXT4).

---

## Step 2: Set Up Partitions
### 5. Associate the SD image with loop devices
```bash
sudo losetup --partscan -f sdcard/sd.img
```
This maps the `sd.img` file to loop devices (e.g., `/dev/loop13`).

### 6. Create mount points
```bash
mkdir boot rootfs
```
Creates directories for the boot and root filesystem partitions.

### 7. Format the partitions
```bash
sudo mkfs.vfat -F -n boot /dev/loop13p1
sudo mkfs.ext4 -L rootfs /dev/loop13p2
```
Formats the partitions as FAT16 and EXT4, respectively.

### 8. Mount the boot partition
```bash
sudo mount /dev/loop13p1 boot/
```
Mounts the FAT16 boot partition.

### 9. Verify mounts
```bash
lsblk
```
Lists block devices and verifies the mounted partitions.

---

## Step 3: Add Boot Content
### 10. Navigate to the boot directory
```bash
cd boot/
```
Changes the current directory to `boot`.

### 11. Create a dummy `zImage` file
```bash
touch zImage
vim zImage
```
Write any content into the `zImage` file using `vim`.

### 12. Return to the `sdcard` directory
```bash
cd ..
```
Navigates back to the `sdcard` directory.

### 13. Unmount the boot partition
```bash
sudo umount boot
```
Unmounts the FAT16 boot partition.

### 14. Sync the filesystem
```bash
sync
```
Ensures all cached data is written to the SD image.

---

## Step 4: Clone and Build U-Boot
### 1. Clone the U-Boot repository
```bash
git clone git@github.com:u-boot/u-boot.git
```
Downloads the latest U-Boot source code.

### 2. Checkout the latest release tag
```bash
cd u-boot
git checkout v2025.01
```
Checks out the specified version of U-Boot.

### 3. Search for the machine configuration
```bash
ls | grep vex
```
Lists machine configurations matching `vex`.

### 4. Set the default configuration
```bash
make vexpress_ca9x4_defconfig
```
Applies the default configuration for `vexpress_ca9x4`.

### 5. Customize the configuration
```bash
make menuconfig
```
- Navigate to **Environment** settings.
- Enable **FAT filesystem**.
- Set the block device, partition, and environment:
  - Block device: `mmc`
  - Partition: `0:1` (FAT partition).

### 6. Set up the cross-compiler
```bash
cat Makefile | grep CROSS_COMPILE
export CROSS_COMPILE=~/x-tools/arm-patrick-linux-musleabihf/bin/arm-patrick-linux-musleabihf-
```
Ensures the correct toolchain is used for ARM.

### 7. Build U-Boot
```bash
make -j12
```
Compiles U-Boot using multiple threads.

---

## Step 5: Run U-Boot with QEMU
### 1. Launch QEMU
```bash
qemu-system-arm -M vexpress-a9 -kernel u-boot -nographic -sd ../../sdcard/sd.img
```
Starts QEMU with the prepared `u-boot` and SD card.

### 2. Interact with U-Boot
- List FAT partition contents:
  ```bash
  ls mmc 0:1
  ```
- Get DRAM address:
  ```bash
  bdinfo
  ```
- Load `zImage` into DRAM:
  ```bash
  fatload mmc 0:1 0x60000000 zImage
  ```
- Verify `zImage` in memory:
  ```bash
  md 0x60000000
  ```
