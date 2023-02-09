//! sbi module.
//! In this module, every functions are used to request the M mode support. 

/// The core syscall fn ~ only with the core assemble codes. 
pub fn syscall(id: usize, args: [3] usize) callconv(.Inline) usize {
    return asm volatile (
        "ecall" 
        : [_] "={x10}" (->usize)
        : [syscall_id] "{x17}" (id) , 
        [arg1] "{x10}" (args[0]) , 
        [arg2] "{x11}" (args[1]) , 
        [arg3] "{x12}" (args[2]) , 
    ); 
}

/// Shutdown support. 
pub fn shutdown() noreturn {
    _ = syscall(call_literals.sbi.shutdown, [3] usize {0, 0, 0, });
    unreachable; 
}

/// Put a char to the console. 
/// Even the input is a 64-bit width, the actually valid support is only 8-bit. 
/// Don't attempt to print a complex chat in only one call -- you should call two or three times to print it completely. 
pub fn consolePutchar(c: usize) callconv(.Inline) void {
    _ = syscall(call_literals.sbi.console_putchar, [3] usize {c, 0, 0, }); 
}

/// the special literals for call literals... 
/// Maybe the better idea is ... use `enum` ? [[TODO]]
pub const call_literals = struct {
    pub const sbi = struct {
        pub const shutdown : usize = 8; 
        pub const console_putchar : usize = 1; 
    };
}; 