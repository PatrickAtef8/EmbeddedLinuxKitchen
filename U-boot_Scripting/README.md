# U-Boot Scripting with QEMU and Cross-Compilation

This directory contains instructions and scripts to set up U-Boot with QEMU for ARM emulation on an x86 machine. It includes steps for creating and testing U-Boot scripts to load a fake kernel image (`zImage`) from an MMC device, TFTP server, or fallback to a GPIO operation.

---

## Prerequisites

### Setting Up U-Boot and QEMU
Ensure you have completed the following:

1. **QEMU Setup:** Installed and configured QEMU for ARM emulation.
2. **Cross-Compilation:** Compiled U-Boot for the ARM architecture using a cross-compiler.
3. **SD Image Preparation:** Created an `sd.img` virtual storage file as part of the U-Boot setup.

---

## Overview

QEMU provides emulated hardware, such as ARM, on an x86 machine. While physical connections like Ethernet cables are used in real hardware setups (e.g., Raspberry Pi connected to a PC), QEMU uses virtual interfaces, such as a TAP interface, to simulate these connections.

In this task, we configure the TAP interface and use a U-Boot script to load a fake kernel image  (`zImage`) (Normal Text File) from:

1. **MMC Device** (`sd.img`).
2. **TFTP Server** (PC acting as the server).
3. **Fallback to GPIO Command** (emulated).

---

## Steps to Achieve the Goal

### 1. Prepare the MMC for the Script
1. Mount the first partition of the `sd.img` file (e.g., `/dev/loop13p1`).
2. Create a `zImage` file in the boot directory:
   ```bash
   sudo touch zImage
   ```
   - `touch zImage`: Creates an empty file named `zImage`.
   
3. Open the file with a text editor to add content:
   ```bash
   sudo vim zImage
   ```
   - `vim zImage`: Opens the `zImage` file in the `vim` text editor.
   - Add a message in the file to indicate it is loaded from the MMC.

### 2. Prepare the TFTP Server
1. Install TFTP server:
   ```bash
   sudo apt install tftpd-hpa
   ```
   - `apt install tftpd-hpa`: Installs the TFTP server package on your machine.

2. Navigate to the TFTP root directory:
   ```bash
   cd /srv/tftp
   ```
   - `/srv/tftp`: Default directory used by the TFTP server to search for files.

3. Go to this directroy and Create a `zImage` file:
   ```bash
   sudo touch zImage
   ```
   - `touch zImage`: Creates an empty file named `zImage` in the TFTP directory.

4. Open the file with a text editor to add content:
   ```bash
   sudo vim zImage
   ```
   - Add a message in the file to indicate it is loaded from the TFTP server.

### 3. Write the U-Boot Script
- Create a U-Boot script (`UbootScript.txt`):

- Convert the script into an executable format:
```bash
sudo mkimage -A arm -T script -C none -n "Boot Script" -d UbootScript.txt UbootScript.scr
```
Explanation of the `mkimage` flags:
- `-A arm`: Specifies the target architecture (ARM).
- `-T script`: Indicates that the file is a script.
- `-C none`: Specifies no compression.
- `-n "Boot Script"`: Provides a description for the script.
- `-d UbootScript.txt`: Input ASCII script file.
- `UbootScript.scr`: Output binary script file.

### 4. Run QEMU with U-Boot
Start QEMU with the following command:
```bash
sudo qemu-system-arm -M vexpress-a9 -kernel u-boot -nographic -sd ~/sdcard/sd.img -net nic -net tap
```
Explanation of the QEMU flags:
- `-M vexpress-a9`: Specifies the machine type to emulate (ARM Versatile Express A9 board).
- `-kernel u-boot`: Uses the U-Boot binary as the kernel.
- `-nographic`: Runs QEMU without a graphical interface (console only).
- `-sd ~/sdcard/sd.img`: Attaches the `sd.img` file as a virtual SD card.
- `-net nic`: Creates a virtual network interface.
- `-net tap`: Connects the virtual network interface to the host's(PC) TAP interface.

### 5. Configure the Network
1. In a separate terminal, set up the TAP interface on the host (PC):
   ```bash
   sudo ip a add 192.168.1.2/24 dev tap0
   ```
   - `ip a add`: Adds a new IP address to an interface.
   - `192.168.1.2/24`: Assigns the IP address `192.168.1.2` with a subnet mask of `255.255.255.0`.
   - `dev tap0`: Specifies the TAP interface to configure.

2. In U-Boot (QEMU):
   ```bash
   set ipaddr 192.168.1.1
   set serverip 192.168.1.2
   ```
   - `set ipaddr`: Sets the IP address of the U-Boot client (QEMU).
   - `set serverip`: Sets the IP address of the TFTP server (host PC).

### 6. Set Boot Command in U-Boot
Set the boot command to load and execute the script on startup:
```bash
setenv bootcmd 'fatload mmc 0:1 0x60000000 UbootScript.scr && source 0x60000000'
```
Explanation:
- `setenv bootcmd`: Sets the default boot command in U-Boot(First thing run in u-boot).
- `fatload mmc 0:1 0x60000000 UbootScript.scr`: Loads the script from the MMC.
- `source 0x60000000`: Executes the script loaded at the specified memory address.

Save the environment variables:
```bash
saveenv
```
- `saveenv`: Saves the current U-Boot environment variables to persistent storage.\

- Exit u-boot
```
CTRL+A then X
```
- Then open u-boot again 
sudo qemu-system-arm -M vexpress-a9 -kernel u-boot -nographic -sd ~/sdcard/sd.img -net nic -net tap
---


## Testing the Script

1. **Case 1: MMC has `zImage`**
   - Ensure the `mmc` boot partition exists.
   - Ensure the `zImage` exists on the MMC.
   - The script will load the `zImage` from MMC.

2. **Case 2: MMC Missing `zImage`**
   - Delete `mmc` boot partition or Delete the `zImage` from MMC.
   - The script will load the `zImage` from the TFTP server.

3. **Case 3: MMC and TFTP Missing `zImage`**
   - Delete the `zImage` from both MMC and TFTP server.
   - The script will execute the GPIO command (no LED operation in QEMU).

---
## Results 

1- If loading `zImage` from `sd.img`

![alt text](/Results/LoadFromSd.img.png)

2- If loading from `zImage` from `tftp`

![alt text](/Results/LoadFromTFTP.png)
![alt text](/Results/Server_CLient.png)
---

## Additional Notes

- **Virtual Interfaces:** QEMU uses virtualization to create a TAP interface, enabling communication between the emulated hardware and the host PC.
- **TFTP Directory:** Ensure that `/srv/tftp` is properly configured and accessible.
- **IP Addressing:** Both the host PC and QEMU need valid IP addresses for network communication.
- **U-Boot Persistence:** Save environment variables to retain configurations across reboots.
