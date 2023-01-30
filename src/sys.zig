pub fn syscall(id: usize, args: [3] usize) callconv(.Inline) usize {
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

pub const call_literals = struct {
    pub const sbi = struct {
        pub const shutdown : usize = 8; 
        pub const console_putchar : usize = 1; 
    };
    usingnamespace sbi; 
    pub const abi = struct {
        pub const write : usize = 64; 
        pub const exit : usize = 93; 
    }; 
}; 

pub const abi = @import("sys/abi.zig");

pub fn write(fd: usize, buf: [*] const u8, len: usize) isize {
    switch (fd) {
        1 => {
            unsafePrintBuffer(buf[0..len]); 
            return @bitCast(isize, len); 
        }, 
        else => @panic("Unsupport fd in sys write"), 
    }
}

pub fn exit(xstate: i32) noreturn {
    @import("root").writer.print("\x1b[32;1m[KERNEL] Application exited with code {}\x1b[0m\n", .{ xstate }) catch |a| switch (a) {}; 
    @import("manager.zig").manager.run(); 
}