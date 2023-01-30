const sys = @import("../sys.zig");
const call_literals = sys.call_literals.abi; 
const syscall = sys.syscall; 

pub fn exit(xstate: i32) noreturn {
    _ = syscall(call_literals.exit, [3] usize { @intCast(u64, @bitCast(u32, xstate)), 0, 0, });  
    unreachable; 
}

pub fn write(fd: usize, buffer: [] const u8) isize {
    var result = syscall(call_literals.write, [3] usize { fd, @ptrToInt(buffer.ptr), buffer.len }); 
    return @bitCast(isize, result);
}