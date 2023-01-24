const root = @import("root"); 

pub fn main() !void {
    var out = root.io.getStdout().writer(); 
    var addr = @ptrToInt(&main); 
    var div10 = @divTrunc(addr, 10); 
    out.print("main addr: 0x{x}\n", .{ addr }) catch |v| switch (v) {}; 
    out.print("after div 10: 0x{x}\n", .{ div10 }) catch |v| switch (v) {}; 
}