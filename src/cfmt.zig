const io = @import("io.zig"); 

pub fn printf(comptime fmt: [] const u8, args: anytype) void {
    const stdout = io.getStdout().writer(); 
    format(stdout, fmt, args) catch |v| switch (v) { };
}

pub fn format(
    writer: anytype, 
    comptime fmt: [] const u8, 
    args: anytype, 
) !void {
    // std description ~ 
    const ArgsType = @TypeOf(args);
    const args_type_info = @typeInfo(ArgsType);
    if (args_type_info != .Struct) {
        @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
    }

    const fields_info = args_type_info.Struct.fields;
    comptime var field_i : usize = 0; 

    comptime var i : usize = 0; 
    inline while (true) { 
        const start_index = i ; 
        inline while (i < fmt.len) : ( i += 1 ) {
            switch (fmt[i]) {
                '%' => {
                    break ; 
                }, 
                else => {}, 
            }
        }
        const end_index = i; 
        if (start_index < end_index) {
            try writer.writeAll(fmt[start_index..end_index]); 
        }
        if (i >= fmt.len) {
            break; 
        }
        if (i + 1 < fmt.len) {
            if (fmt[i+1] == fmt[i]) {
                try writer.writeByte('%'); 
            } else {
                switch (fmt[i+1]) {
                    'd' => {
                        if (field_i >= fields_info.len) {
                            @compileError("Expected a signed integer for operator '%d' but missing"); 
                        }
                        const val = @field(args, fields_info[field_i].name); 
                        try writeDecimalInt(writer, val); 
                    }, 
                    'u' => {
                        if (field_i >= fields_info.len) {
                            @compileError("Expected an unsigned integer for operator '%u' but missing"); 
                        }
                        const val = @field(args, fields_info[field_i].name); 
                        try writeDecimalUint(writer, val); 
                    }, 
                    'x' => {
                    }, 
                    'X' => {
                    }, 
                    's' => {
                        if (field_i >= fields_info.len) {
                            @compileError("Expected a string for operator '%s' but missing"); 
                        }
                        const slice = @field(args, fields_info[field_i].name); 
                        _ = try writer.writeAll(slice); 
                    }, 
                    else => @compileError("Invalid operator"),
                } 
                field_i += 1; 
            }
            i += 2; 
        }
    }
    if (field_i != fields_info.len) {
        @compileError("Some unused arguments in 'printf' fn. ");
    }
}

fn writeDecimalInt(writer: anytype, value: anytype) !void {
    const value_type = @typeInfo(@TypeOf(value));
    if (value_type != .Int and value_type != .ComptimeInt) {
        @compileError("Decimal operator should use on signed integer"); 
    }
    var buffer: [40] u8 = undefined; 
    var index : usize = buffer.len - 1; 
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
            _ = try writer.writeAll(buffer[index..buffer.len]);
            return ; 
        }
        index -= 1; 
    } 
}

fn writeDecimalUint(writer: anytype, value: anytype) !void {
    const value_type = @typeInfo(@TypeOf(value));
    if (value_type != .Uint and value_type != .ComptimeUInt) {
        @compileError("Decimal operator should use on unsigned integer"); 
    }
    var buffer: [40] u8 = undefined; 
    var index : usize = buffer.len - 1; 
    if (value == 0) {
        try writer.writeByte('0');  
        return ; 
    } 
    comptime var tmp = value; 
    inline while (true) {
        var rem = @rem(tmp, @as(i32, 10)); 
        tmp = @divFloor(tmp, 10);
        buffer[index] = @intCast(u8, rem) + @as(u8, '0'); 
        if (tmp == 0) {
            _ = try writer.writeAll(buffer[index..buffer.len]);
            return ; 
        }
        index -= 1; 
    } 
}