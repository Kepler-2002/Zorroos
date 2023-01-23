const io = @import("std").io; 

pub fn writeDecimalInt(writer: anytype, value: i32) !void {
    var buffer: [10] u8 = undefined; 
    var index : usize = 9; 
    if (value == 0) {
        try writer.writeByte('0');  
        return ; 
    } 
    var tmp = value; 
    while (true) {
        var rem = @rem(tmp, @as(i32, 10)); 
        tmp = @divFloor(tmp, 10);
        buffer[index] = @intCast(u8, rem) + @as(u8, '0'); 
        if (tmp == 0) {
            _ = try writer.write(buffer[index..buffer.len]);
            return ; 
        }
        index -= 1; 
    } 
}