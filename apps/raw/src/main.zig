pub export fn _start() callconv(.C) void { 
    asm volatile ( 
        \\li x10, 2
        \\li x17, 93
        \\ecall 
    ); 
}