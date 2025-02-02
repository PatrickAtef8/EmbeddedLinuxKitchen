SECTIONS {
    . = 0x81000; /* Start at 0x81000 to go on this address after load the program into ram in this address*/
    .text : {
        *(.text)
    }
    .data : {
        *(.data)
    }
    .bss : {
        *(.bss)
    }
}

