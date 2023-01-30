//! This part is the IO part. 
//! The class `Stdout` is the core object defined to give the output abstract. 
//! Use the fn `getStdOut` to get it! 

/// Get the stdout output abstract, actually no-op now. 
pub fn getStdOut() callconv(.Inline) Stdout {
    return Stdout {}; 
}

pub const writer = ( Stdout {} ).writer(); 

/// The std support. 
const std = @import("std"); 

/// The output operator is dependent by the sbi interface. 
const sys = @import("sbi.zig");

/// The output abstract, no member variables till now. 
const Stdout = struct {

    fn write(_: Stdout, data: []const u8) EmptyError!usize {
        // do not promote the efficiency of the program. 
        // @call(.{ .modifier = .always_inline, }, sys.unsafePrintBuffer, .{ data }); 
        sys.unsafePrintBuffer(data); 
        return data.len; 
    }

    pub fn writer(self: Stdout) Writer {
        return .{
            .context = self, 
        }; 
    }

}; 

/// Empty set of error. Because we won't meet error when we output by `sbi`. 
const EmptyError = error {};

const Writer = std.io.Writer(
    Stdout, 
    EmptyError, 
    Stdout.write
); 
