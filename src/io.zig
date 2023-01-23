pub fn getStdout() Stdout {
    return Stdout {}; 
}

const std = @import("std"); 

const sys = @import("sys.zig");

const Stdout = struct {

    fn write(_: Stdout, data: []const u8) error {} !usize {
        @call(.{ .modifier = .always_inline, }, sys.unsafePrintBuffer, .{ data }); 
        // sys.unsafePrintBuffer(data); 
        return data.len; 
    }

    pub fn writer(self: Stdout) Writer {
        return .{
            .context = self, 
        }; 
    }

}; 

const EmptyError = error {};

const Writer = std.io.Writer(
    Stdout, 
    EmptyError, 
    Stdout.write
); 
