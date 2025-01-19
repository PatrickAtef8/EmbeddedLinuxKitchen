# Rassbery pi model 3B+ as a Bare Metal GPIO Control

This project demonstrates how to write a bare-metal program to control GPIO pins on a Raspberry Pi model 3B+. I used three key files: `gpio_control.S`, `gpio_control.c`, and `gpio_control.ld`, along with several compiler and linker commands by my cross compiler from crosstool-ng to build the project. Below, here is the explaination of the steps done.

## File Breakdown

### 1. `gpio_control.S` (Assembly File)

This file contains the startup code that runs before the main program. It sets up the stack pointer, and jumps to the `main` function.

- **Key components**:
  - `ldr x0, =0x800000`: Sets the stack pointer to `0x800000`.
  - `ldr x0, =main`: Loads the address of the `main` function and branches to it.

### 2. `gpio_control.c` (C File)

This is the main program, which configures GPIO pins and enters an infinite loop to keep the program running.

- **Key components**:
  - `volatile unsigned int *gpio_fsel1 = (unsigned int *)GPFSEL1;`: Declares a pointer to the GPIO Function Select register.
  - `*gpio_fsel1 |= (1 << 21);`: Sets GPIO 17 as an output pin.
  - `*gpio_set0 = (1 << 17);`: Sets GPIO 17 high (turns it on) "I connected the led in pin 11.
  - `while (1);`: Prevents the program from exiting by entering an infinite loop.

### 3. `gpio_control.ld` (Linker Script)

This file defines the memory layout of the program. It ensures that the program starts at a specific memory location (`0x81000`) and organizes the sections of the program.

- **Key components**:
  - `. = 0x81000;`: Sets the starting address for the program’s code.
  - `.text`, `.data`, and `.bss` sections: These define where the program's executable code, initialized data, and uninitialized data are placed in memory.
---

## Commands Explanation
1- 
 ```
 aarch64-patrick-linux-gnu-gcc -c -nostdlib -o gpio_control.o gpio_control.c
```
This command compiles the C source file `gpio_control.c` into an object file (`gpio_control.o`) for the ARM architecture. The flags used are:

- `-c`: Compile the source file into an object file, without linking.
- `-nostdlib`: Tells the compiler to not use system calls because the project is full dependent on u-boot (no image), this is common for bare-metal programming where we do not rely on the operating system or standard libraries.
- `-o gpio_control.o`: Specifies the name of the output object file.

- **What it does**: It translates the C source code into machine code for the ARMv8-A architecture.

2-
 ```
aarch64-patrick-linux-gnu-as -o gpio_controlST.o gpio_control.S
```
This command assembles the assembly source file `gpio_control.S` into an object file (`gpio_controlST.o`). The flags used are:

- `-o gpio_controlST.o`: Specifies the name of the output object file.

- **What it does**: It translates the assembly code into an object file that the linker can later combine with other object files.

3- 
  ```
  aarch64-patrick-linux-gnu-ld -nostdlib -T gpio_control.ld -o gpio_control.elf gpio_controlST.o gpio_control.o
  ```
This command links the object files (`gpio_controlST.o` and `gpio_control.o`) to create an executable ELF file (`gpio_control.elf`). The flags used are:

- `-nostdlib`:  Tells the compiler to not use system calls because the project is full dependent on u-boot (no image), this is common for bare-metal programming where we do not rely on the operating system or standard libraries.
- `-T gpio_control.ld`: Specifies the linker script (`gpio_control.ld`) to use. Linker scripts control the memory layout of the program.
- `-o gpio_control.elf`: Specifies the name of the output ELF executable file.

- **What it does**: It combines the object files and links them to create a final executable in the ELF format.

4-
 ```
 aarch64-patrick-linux-gnu-objcopy -O binary gpio_control.elf gpio_control.bin
```
This command converts the ELF file (`gpio_control.elf`) into a raw binary file (`gpio_control.bin`). The flags used are:

- `-O binary`: Specifies the output format as raw binary. The `objcopy` tool is used to convert between different object file formats.

- **What it does**: It converts the ELF file into a binary file that can be loaded onto a device for execution.


### sd card preparation and minicom 
**Please check the u-boot previous folders**

### In U-boot after minicom 
```
fatload mmc 0:1 0x81000 gpio_control.bin 
``` 
```
go 0x81000
```
**As you tell the linker that the gpio_control.bin application will start on address 0x81000 so you shoul use fatload to load this program in this specific address then us go to just go to this address where you can find the program as it loaded to RAM by fatload**
NOW, the led is on 


## Summary

This project involves bare-metal programming on an ARM-based system (such as the Raspberry Pi). The program directly manipulates GPIO registers to control hardware, without relying on an operating system. The `.S` file handles initialization, the `.c` file contains the program logic, and the `.ld` file ensures correct memory layout during linking. The commands provided above explain how to compile, assemble, link, and convert the program into a binary format suitable for loading onto the device.
