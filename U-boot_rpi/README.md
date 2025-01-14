# U-Boot Setup for Raspberry Pi 3 Model B+

This guide provides a step-by-step process to build U-Boot for the Raspberry Pi 3 Model B+ and configure an SD card to boot U-Boot. Each step and command is explained for clarity.

---

## Prerequisites

- A Raspberry Pi 3 Model B+.
- A physical SD card (16GB in this example).
- A cross-compilation toolchain for AArch64.
- The U-Boot source code.

---

## Steps to Compile U-Boot

### 1. Locate the RPi 3 B+ Configuration
Search for the Raspberry Pi 3 Model B+ defconfig file in the U-Boot source directory:
```bash
find . -name "rpi_3_b_plus_defconfig"
```

### 2. Clone the U-Boot Repository
Clone the U-Boot repository (if not already cloned) and navigate to the directory. Follow the steps outlined in the U-Boot_Work README file for building U-Boot.

### 3. Verify the Toolchain Prefix
Check the Makefile to confirm the `CROSS_COMPILE` prefix:
```bash
cat Makefile | grep CROSS_COMPILE
```

### 4. Export the Cross-Compiler Path
Set the `CROSS_COMPILE` environment variable to your AArch64 toolchain path:
```bash
export CROSS_COMPILE=~/x-tools/aarch64-patrick-linux-gnu/bin/aarch64-patrick-linux-gnu-
```

### 5. Compile U-Boot
Run the build process with multiple threads (adjust `-j` based on your CPU):
```bash
make rpi_3_b_plus_defconfig
make -j12
```

The output will include `u-boot` and `u-boot.bin` binaries.

---

## Preparing the SD Card

### 1. Partition the SD Card
Use `cfdisk` to divide the SD card into two partitions:
```bash
cfdisk /dev/mmcblk0
```
- **Partition 1**: Bootable, FAT16, size 200MB.
- **Partition 2**: Extended, occupies the remaining space.

### 2. Format the Partitions
Format the partitions with the appropriate file systems:
```bash
sudo mkfs.vfat -F 16 -n boot /dev/mmcblk0p1
sudo mkfs.ext4 -L rootfs /dev/mmcblk0p2
```

### 3. Create Mount Points
Create directories for mounting the partitions:
```bash
mkdir boot rootfs
```

### 4. Mount the Partitions
Mount partition 1 to `boot`:
```bash
sudo mount /dev/mmcblk0p1 boot
```
Mount partition 2 to `rootfs`:
```bash
sudo mount /dev/mmcblk0p2 rootfs
```

### 5. Copy Files to Boot Partition
Copy all required files, including `u-boot.bin`, to the boot partition:
```bash
cp /path/to/ImpFiles/* boot/
```
Ensure `config.txt` in the `ImpFiles` directory points to `u-boot.bin` as the kernel.

### 6. Unmount the Partitions
Unmount the partitions after copying the files:
```bash
sudo umount boot rootfs
```

---

## Booting the Raspberry Pi

### 1. Insert the SD Card
Insert the prepared SD card into the Raspberry Pi.

### 2. Connect via USB-TTL
Connect the Raspberry Pi to your computer using a USB-TTL serial cable.

### 3. Start Minicom
Open a terminal to interact with U-Boot using Minicom:
```bash
sudo minicom -D /dev/ttyUSB0
```

---

## U-Boot Commands

Once U-Boot starts, execute the following commands:

### 1. List Files on the Boot Partition
```bash
ls mmc 0:1
```
This lists the files on the first partition of the SD card.

### 2. Display Board Information
```bash
bdinfo
```
This shows detailed information about the Raspberry Pi board.

### 3. Display Memory Contents
```bash
md <address>
```
Replace `<address>` with the desired memory address to view its contents.

---

## Notes
- Ensure the `config.txt` file matches the setup to use `u-boot.bin` as the boot file.
- Adjust paths and commands as per your environment setup.
- For troubleshooting, check the serial output for error messages.
