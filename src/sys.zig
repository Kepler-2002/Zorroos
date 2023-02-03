/// 
const sbi = @import("sbi.zig"); 
pub const call_literals = sbi.call_literals.abi; 
pub const syscall = sbi.syscall; 

pub fn exit(xstate: i32) noreturn {
    _ = syscall(call_literals.exit, [3] usize { @intCast(usize, @bitCast(u32, xstate)), 0, 0, });  
    unreachable; 
}

pub fn write(fd: usize, buffer: [] const u8) isize {
    var result = syscall(call_literals.write, [3] usize { fd, @ptrToInt(buffer.ptr), buffer.len }); 
    return @bitCast(isize, result);
}