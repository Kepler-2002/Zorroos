const root = @import("root"); 

pub fn main() !void {
    var out = root.io.getStdOut().writer(); 
    var addr = @ptrToInt(&main); 
    out.print("main addr: 0x{x}\n", .{ addr }) catch |v| switch (v) {}; 
    // var div10 = @divTrunc(addr, 10); 
    // out.print("after div 10: 0x{x}\n", .{ div10 }) catch |v| switch (v) {}; 
}