pub const std = @import("std");

pub const sys = @import("sys.zig");
const rt = @import("rt.zig");
pub const io = @import("io.zig");

pub const fmt = struct {
    usingnamespace @import("cfmt.zig");
}; 

comptime {
    _ = fmt; 
}

pub export var kernel_stack : [4096 * 2] u8 align(4096) = undefined; 

pub fn panic(error_message: []const u8, stack: ?*std.builtin.StackTrace, len: ?usize) noreturn {
    _ = stack; 
    _ = len; 
    // todo: lock it... 
    io.getStdOut().writer().print("\x1b[31;1m{s}\x1b[0m\r\n", .{ error_message }) catch unreachable; 
    sys.shutdown(); 
}

export fn main() callconv(.C) void {
    rt.emptyBss(); 
    @import("kernel.zig").main() catch |err| switch (err) {
    }; 
    var p = c_run.cmain(); 
    if (p == 0) {
        @panic("end of program");
    } else {
        @panic("error & end");
    }
}

const c_run = @cImport( @cInclude("cmain.c") ); 