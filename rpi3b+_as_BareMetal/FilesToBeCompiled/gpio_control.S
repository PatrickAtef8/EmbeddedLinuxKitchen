    .globl _start
_start:

    // Initialize the stack
    ldr x0, =0x800000  // Example stack pointer (adjust as needed)
    mov sp, x0
    
    // Branch to main
    ldr x0, =main       
    br x0              

    // Infinite loop 
hang:
    b hang

