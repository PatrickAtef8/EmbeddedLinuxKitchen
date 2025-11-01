# Embedded Linux Kitchen 🐧

A comprehensive hands-on repository for building embedded Linux systems from scratch. This project takes you through the complete journey of creating custom embedded Linux distributions, from toolchain compilation to init system configuration.

## Repository Structure

This repository is organized as a progressive learning path through the embedded Linux development stack:

### Core Components

#### **01. Toolchain Work**
Building and configuring cross-compilation toolchains using crosstool-ng. Learn to create the foundational tools needed to compile code for embedded targets.

#### **02. U-boot Qemu Work**
U-Boot bootloader configuration and testing in QEMU virtual environment. Perfect for learning bootloader concepts without physical hardware.

#### **03. U-boot rpi3b+ Work**
Raspberry Pi 3B+ specific U-Boot configuration and deployment. Real hardware bootloader implementation.

#### **04. rpi3b+ as BareMetal**
Bare-metal programming on Raspberry Pi 3B+. Understanding hardware initialization without an operating system.

#### **05. U-boot Scripting**
Advanced U-Boot scripting techniques for automated boot sequences and environment configuration.

#### **06. Kernel busybox Qemu Work**
Linux kernel compilation and BusyBox integration in QEMU. Build minimal Linux systems in a virtual environment.

#### **07. Kernel busybox rpi Work**
Raspberry Pi specific kernel and BusyBox configuration. Deploy custom Linux on real hardware.

### Init Systems

#### **08. Init Process busybox init**
Implementing BusyBox's simple init system. Learn the basics of process initialization.

#### **09. Init Process SysVinit**
Classic System V init system implementation. Understanding traditional Linux initialization.

#### **10. Init Process Systemd**
Modern systemd initialization. Configure contemporary init with advanced service management.

## 🛠️ Key Technologies

- **Toolchains**: crosstool-ng for cross-compilation
- **Bootloaders**: U-Boot for ARM platforms
- **Kernels**: Linux kernel customization and configuration
- **Userspace**: BusyBox for minimal embedded utilities
- **Build Systems**: Buildroot for automated system generation
- **Hardware**: Raspberry Pi 3B+, ARM Vexpress (QEMU)
- **Emulation**: QEMU for virtual development and testing

## Learning Objectives

1. **Understand the embedded Linux boot process** from power-on to userspace
2. **Master cross-compilation** and toolchain creation
3. **Configure bootloaders** for different platforms
4. **Customize Linux kernels** for embedded targets
5. **Build minimal root filesystems** with BusyBox
6. **Implement various init systems** and understand their differences
7. **Work with both virtual and physical hardware**


### Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd EmbeddedLinuxKitchen

# Start with toolchain creation
cd 01.Toolchain_Work

# Follow the README in each directory for specific instructions
```

## Recommended Learning Path

1. **Start with 01.Toolchain_Work** - Build your cross-compiler
2. **Move to 02.U-boot_Qemu_Work** - Learn bootloader basics in QEMU
3. **Progress to 06.Kernel_busybox_Qemu_Work** - Boot a minimal Linux in QEMU
4. **Try 08-10.Init_Process_*** - Understand different init systems
5. **Advance to Raspberry Pi sections** (03, 07) when ready for real hardware

## 🔧 Build Artifacts

The repository includes pre-built components for quick testing:
- `Image` / `zImage` - Compiled Linux kernel images
- `u-boot` - U-Boot bootloader binaries
- `busybox` - BusyBox userspace utilities
- `rootramfs` - Root filesystem examples
- `*.dtb` - Device tree blobs for hardware description

## Contributing

Each directory contains specific experiments and configurations. Feel free to:
- Add new platform support
- Improve documentation
- Share configuration optimizations
- Report issues and solutions

## Notes

- Each numbered directory is self-contained with its own documentation
- Start with QEMU-based projects before moving to physical hardware
- Keep track of kernel versions and toolchain compatibility
- Use version control to experiment safely

## Resources

- [Linux From Scratch](http://www.linuxfromscratch.org/)
- [Buildroot Manual](https://buildroot.org/docs.html)
- [U-Boot Documentation](https://www.denx.de/wiki/U-Boot)
- [BusyBox Documentation](https://busybox.net/)
- [ARM Documentation](https://developer.arm.com/)

## ⚖️ License

Refer to individual component licenses (Linux kernel: GPLv2, U-Boot: GPLv2, BusyBox: GPLv2)

---

**Happy Embedded Linux Hacking!**

*This repository is a learning kitchen - experiment, break things, and understand embedded Linux from the ground up.*