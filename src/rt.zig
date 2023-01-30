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

comptime {
    asm( 
        \\.align 3
        \\.section .data 
        \\.global app_numbers
        \\app_numbers: 
        \\.quad 2 
        \\.quad app0_start
        \\.quad app1_start
        \\.quad app1_end 
        \\.section .data 
        \\.global app0_start
        \\.global app0_end 
        \\app0_start: 
        \\.incbin "apps/hello/zig-out/bin/hello.bin"
        \\app0_end: 
        \\.section .data
        \\.global app1_start
        \\.global app1_end
        \\app1_start:
        \\.incbin "apps/view/zig-out/bin/view.bin"
        \\app1_end:
    );
}