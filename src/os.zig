//! os kernel module, including some modules: 
//! - (sbi) sbi call : globally sbi call, without sync support / async support. [[TODO]]
//! - (abi) abi call : globally abi call handle. 
//! - (rt) runtime : export the symbol `_start` for program start, init the stack. implicitly some global variables would init here. 
//! - (io) output support: define the terminal output (by sbi interface) format object: writer. 
//! - 

/// sbi support 
pub const sbi = @import("sbi.zig"); 
/// c runtime support 
pub const rt = @import("rt.zig"); 
/// output support 
pub const io = @import("io.zig"); 
/// log support 
pub const log = @import("log.zig");
/// std lib support 
pub const std = @import("std"); 


/// 4K stack, align is the same... it would at the start of the page actually. 
pub var user_stack : [4096] u8 align(4096) = undefined; 

/// global panic support 
pub fn panic(error_message: []const u8, stack: ?*std.builtin.StackTrace, len: ?usize) noreturn {
    _ = stack; 
    _ = len; 
    log.err("panic: {s}", .{ error_message, } ); 
    sbi.shutdown(); 
}

pub fn init() void {
    inline for (rt.init) |r | r(); 
    set_trap(); 
}

const root = @import("root"); 

fn set_trap() callconv(.C) void {
    // the addr [XLEN - 1: 2] handle addr ; 
    // mode = 0 : pc to base 
    // assume the base is 4 byte aligned.
    const base = @ptrToInt(&root.trap);
    if (base & 0x3 != 0) {
        @panic("trap base not 4 byte aligned!"); 
    }

    // set the trap handle
    asm volatile (
        \\csrw stvec, %[val]
        : : [val] "r" (base) 
    ); 
}

comptime {
    _ = @import("elf.zig"); 
}