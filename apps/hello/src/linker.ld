OUTPUT_ARCH(riscv)
ENTRY(_start)
BASE_ADDRESS = 0x80400000;

SECTIONS {
    . = BASE_ADDRESS; 
    .text : {
        *(.text.entry) 
        *(.text .text.*)
    }
    . = ALIGN(4K); 
    .rodata : {
        *(.rodata .rodata.*) 
    }
    . = ALIGN(4K); 
    .data : {
        *(.data .data.*)
    }
    . = ALIGN(4K); 
    .bss : {
        sbss = .; 
        *(.bss .bss.*)
        ebss = .; 
    }
    .shstrtab : {
        *(.shstrtab .shstrtab.*)
    }
    .strtab : {
        *(.strtab .strtab.*)
    }
    .symtab : {
        *(.symtab .symtab.*)
    }
    /DISCARD/ : {
        *(.*)
    }
}