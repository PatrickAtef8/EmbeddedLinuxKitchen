    .globl _start
_start:
    // Initialize the stack
    ldr x0, =0x800000  // Example stack pointer (adjust as needed)
    mov sp, x0

    // Optional: Clear cache (safe initialization)
    mov x0, #0          // Cache operation
    msr SCTLR_EL1, x0   // Disable caches and alignment checks
    
    // Branch to main
    ldr x0, =main       // Load main's address
    br x0               // Branch to main

    // Infinite loop to avoid exiting
hang:
    b hang

