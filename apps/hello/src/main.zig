const std = @import("std"); 

pub export fn _start() callconv(.C) void { 
    const h = "Hello World\n"; 
    std.io.getStdOut().writer().print("{s}", .{ h }) catch unreachable; 
    std.os.exit(2); 
}