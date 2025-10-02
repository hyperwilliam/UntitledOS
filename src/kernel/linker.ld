/* I Dont Know How To Make A Linker File, But I Will Try. */
ENTRY(kernel_main)

SECTIONS
{
    /* The kernel will be loaded at 0x8000 */
    . = 0x8000;
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
        *(COMMON)
    }
}

