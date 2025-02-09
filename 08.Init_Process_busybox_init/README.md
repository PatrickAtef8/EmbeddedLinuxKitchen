# Init Process Using BusyBox Init

## Overview
This project demonstrates how to set up an `init` system using BusyBox `init`. The goal is to utilize the `init` process from BusyBox to initialize the system and then switch the root filesystem. This method is crucial for embedded Linux systems, especially when using an `initramfs` to bootstrap the system before switching to the actual root filesystem.

## Why Use BusyBox Init?
BusyBox provides a lightweight `init` system that is well-suited for embedded environments where minimalism and efficiency are key. The `init` process is the first process executed by the Linux kernel after booting. It is responsible for initializing the system, setting up necessary filesystems, and spawning the first shell or user processes.

Using `BusyBox init` allows:
- A minimal and efficient boot process.
- Complete control over system initialization.
- Easy customization for embedded devices.

## Setting Up the Root Filesystem

### 1. Navigate to the Working Directory
```sh
cd ~/EmbeddedLinuxKitchen/rootramfs
```

### 2. Create Required Directories
```sh
mkdir etc proc boot sys NewRoot
```
These directories are essential for:
- `etc`: Configuration files.
- `proc`: The proc filesystem for kernel process information.
- `boot`: Contains boot-related files.
- `sys`: The sysfs filesystem for kernel objects.
- `NewRoot`: The new root filesystem to switch to.

### 3. Copy Essential Binaries
```sh
cp -r /EmbeddedLinuxKitchen/busybox/_install/{bin,sbin,usr} .
```
Copy this directories from busybox (Compiled Statically --> from menuconfig of busybox)

## Configuring Init

### 1. Create the `etc/init.d` Directory and Required Files
```sh
cd etc
mkdir init.d
cd init.d
touch rcS
```
These steps set up the system initialization scripts:
- `etc/init.d/rcS`: The startup script executed during system initialization.

### 2. Create the `inittab` File
```sh
touch ../inittab
```
The `inittab` file is the configuration file for `init` and defines how the system boots.

### 3. Directory Structure
```sh
tree -d
```
Expected output:
```
.
├── bin
├── boot
├── etc
│   └── init.d
├── NewRoot
├── proc
├── sbin
├── sys
└── usr
    ├── bin
    └── sbin
```

`etc` directory tree:
```sh
tree etc
```
Expected output:
```
.
├── init.d
│   └── rcS
└── inittab
```

## Configuring `inittab`
Edit `inittab`:
```sh
vim etc/inittab
```
Add the following lines:
```ini
::sysinit:/etc/init.d/rcS
console::askfirst:/bin/sh
```
Explanation:
- `::sysinit:/etc/init.d/rcS`: Runs the `rcS` script as the first system initialization process.
- `console::askfirst:/bin/sh`: Spawns a shell that waits for user input before proceeding.

## Additional options:
### Inittab Configuration Guide
 - From `init.c`.

### Action Flags from `init.c`

- `SYSINIT (0x01)`: Runs system initialization commands.
- `WAIT (0x02)`: Executes after `SYSINIT` and waits for completion.
- `ONCE (0x04)`: Runs once after `WAIT` but does not wait for completion.
- `RESPAWN (0x08)`: Starts processes after `ONCE` and restarts them if they exit.
- `ASKFIRST (0x10)`: Similar to `RESPAWN`, but requires the user to press `<Enter>` before execution.
- `CTRLALTDEL (0x20)`: Executes when `Ctrl + Alt + Del` is pressed; typically used for system reboot.
- `SHUTDOWN (0x40)`: Runs before killing processes when halting, rebooting, or powering off.
- `RESTART (0x80)`: Executes on `SIGQUIT`, restarting the system by replacing the `init` process.

### `/etc/inittab` Example Configuration

```plaintext
::sysinit:/etc/init.d/rcS      # Run system initialization script
::wait:/sbin/fsck -A -y        # Run filesystem check and wait
::once:/bin/mount -a           # Mount all filesystems once
tty1::respawn:/bin/sh          # Spawn a shell on tty1
console::askfirst:/bin/sh      # Wait for user input before spawning shell
::ctrlaltdel:/sbin/reboot      # Reboot on Ctrl + Alt + Del
::shutdown:/sbin/shutdown -h now  # Shutdown cleanly
```
## Configuring `rcS`
Edit `rcS`:
```sh
vim etc/init.d/rcS
```
Add the following lines:
```sh
#!/bin/sh

mount -t sysfs null /sys
mdev -s
mount -t proc null /proc
mount -t vfat /dev/mmcblk0p1 /boot
mount -t ext4 /dev/mmcblk0p2 /NewRoot
```
Explanation:
- `mount -t sysfs null /sys`: Mounts the sysfs filesystem.
- `mdev -s`: Initializes device nodes.
- `mount -t proc null /proc`: Mounts the proc filesystem.
- `mount -t vfat /dev/mmcblk0p1 /boot`: Mounts the boot partition.
- `mount -t ext4 /dev/mmcblk0p2 /NewRoot`: Mounts the second partition as the new root.

Make `rcS` executable:
```sh
chmod +x etc/init.d/rcS
```

## Creating `rootramfs.cpio`
```sh
find . | cpio -H newc -ov > rootramfs.cpio
```
This command creates an initial RAM filesystem image for booting.

## Copying `rootramfs.cpio` to the Boot Partition
```sh
sudo mount /dev/loop16p1 ~/sdcard/boot
sudo cp ~/EmbeddedLinuxKitchen/rootramfs/rootramfs.cpio ~/sdcard/boot
```
This ensures that the RAM disk is available during boot.

## Updating Boot Configuration
Edit `extlinux.conf`:
```sh
sudo vim /extlinux/extlinux.conf
```
Ensure it contains:
```ini
rdinit=/sbin/init
```
This tells the kernel to use BusyBox `init`.

## Preparing the Root Filesystem
Mount the root filesystem:
```sh
sudo mount /dev/loop16p2 rootfs/
cd rootfs
```
Create necessary directories:
```sh
mkdir proc sys tmp dev
```
Unmount the filesystem:
```sh
cd ..
sudo umount rootfs
```

## Running QEMU
Run the system in QEMU:
```sh
qemu-system-arm -M vexpress-a9 -kernel ~/EmbeddedLinuxKitchen/u-boot/u-boot -nographic -sd ~/sdcard/sd.img
```
After boot, you will see a message due to `askfirst`. Press `Enter` to access the shell.
![askfirst](Results/askfirst.png)

### Switching to the New Root Filesystem
```sh
exec chroot /NewRoot /bin/sh
```
This command replaces the current shell with a new shell running in `NewRoot`, effectively switching the root filesystem.

**I added this to pass any unwanted message to the black hole /dev/null**
```
2> /dev/null 
```
![switchroot](Results/switchroot.png)

## Conclusion
This setup demonstrates how to use BusyBox `init` with an `initramfs`, mount a new root filesystem, and switch to it. This is a fundamental concept for embedded Linux systems and custom boot environments.
