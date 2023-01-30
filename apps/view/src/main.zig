const lib = @import("kernel-sys");

pub export fn _start() callconv(.C) void {
    const ptr = @intToPtr(*i32, 0x666664); 
    ptr.* = 0; 
    lib.abi.exit(0); 
}