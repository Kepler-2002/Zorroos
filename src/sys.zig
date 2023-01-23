fn syscall(id: usize, args: [3] usize) callconv(.Inline) usize {
    return asm volatile (
        "ecall" 
        : [ret] "={x10}" (->usize)
        : [number] "{x17}" (id) , 
        [arg1] "{x10}" (args[0]) , 
        [arg2] "{x11}" (args[1]) , 
        [arg3] "{x12}" (args[2]) , 
    ); 
}

pub fn shutdown() noreturn {
    _ = syscall(call_literals.shutdown, [3] usize {0, 0, 0, });
    unreachable; 
}

pub fn consolePutchar(c: usize) callconv(.Inline) void {
    _ = syscall(call_literals.console_putchar, [3] usize {c, 0, 0, }); 
}

pub fn unsafePrintBuffer(chars : []const u8) void {
    for (chars ) |c| {
        consolePutchar(@intCast(usize, c));
    }
}

const call_literals = struct {
    const sbi = struct {
        const shutdown : usize = 8; 
        const console_putchar : usize = 1; 
    };
    usingnamespace sbi; 
}; 
