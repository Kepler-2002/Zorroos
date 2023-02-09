//! os kernel module, including some modules: 
//! - (sbi) sbi call : globally sbi call, without sync support / async support. [[TODO]]
//! - (abi) abi call : globally abi call handle. 
//! - (rt) runtime : export the symbol `_start` for program start, init the stack. implicitly some global variables would init here. 
//! - (io) output support: define the terminal output (by sbi interface) format object: writer. 
//! - 

pub const sbi = @import("sbi.zig"); 

pub const abi = @import("abi.zig"); 

pub const rt = @import("rt.zig"); 
pub const runtime = rt; 

pub const io = @import("io.zig"); 
pub const @"input&output" = io; 

pub const std = @import("std"); 

pub const writer = io.writer; 

/// 4K stack, align is the same... it would at the start of the page actually. 
pub var user_stack : [4096] u8 align(4096) = undefined; 

/// global panic support 
pub fn panic(error_message: []const u8, stack: ?*std.builtin.StackTrace, len: ?usize) noreturn {
    _ = stack; 
    _ = len; 
    // sync / lock support desired [[TODO]]
    writer.print("\x1b[31;1m{s}\x1b[0m\r\n", .{ error_message }) catch |a| switch (a) {}; 
    sbi.shutdown(); 
}

pub fn init() !void {
    inline for (rt.init) |r | r(); 
}

comptime {
    _ = @import("elf.zig"); 
}