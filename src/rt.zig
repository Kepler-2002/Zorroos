comptime {
    asm (
        \\.section .text.my_entry 
        \\.globl _start 
        \\_start: 
        \\  la sp, boot_stack_top
        \\  call main 
        \\.section .bss.stack 
        \\.globl boot_stack
        \\boot_stack:
        \\.space 4096 * 16 * 16
        \\.globl boot_stack_top
        \\boot_stack_top: 
    ); 
}

extern const sbss : u8; 
extern const ebss : u8; 

pub fn emptyBss() void {
    const start_ptr : [*]u8 = @ptrCast([*]u8, &sbss); 
    const length = @ptrToInt(&ebss) - @ptrToInt(&sbss); 
    @memset(start_ptr, 0, length);
}