const std = @import("std");

const lib = @import("kernel"); 

pub export fn _start() callconv(.C) void {
    const api = lib; 
    const str = "Hello World\n"; 
    var slice2 : [str.len] u8 = undefined; 
    inline for (str) |c, i| {
        slice2[i] = c; 
    }
    _ = api.write(1, &slice2); 
    api.exit(21);
}