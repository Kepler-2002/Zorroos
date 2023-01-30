//! In this module, we would handle the abi call, and return it well. 

/// sbi support, write fn needs this support. 
const sbi = @import("sbi.zig"); 

/// output support 
const writer = @import("io.zig").writer; 

/// write support: only fd = 1 is valid now. 
pub fn write(fd: usize, bytes: [] const u8) usize {
    switch (fd) {
        1 => sbi.unsafePrintBuffer(bytes), 
        else => {
            writer.print("\x1b[31;1m[src/abi.zig:8:10] Invalid file descriptor for `write`: {}\x1b[0m\n", .{ fd }) catch unreachable; 
            sbi.shutdown(); 
        }
    }
    return bytes.len; 
}

/// exit user-mode application support: exit this application and then run the next one. 
pub fn exit(xstate: i32) noreturn {
    const manager = @import("manager.zig").manager; 
    const prefix = if (xstate == 0) "\x1b[32;1m" else "\x1b[33;1m"; 
    const now_index = manager.current; 
    writer.print("{s} User mode application {} ends, with the exit code: {}. \x1b[0m", .{ prefix, now_index, xstate, }) catch unreachable; 
    manager.run(); 
}