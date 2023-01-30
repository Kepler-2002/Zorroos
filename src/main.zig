pub const std = @import("std");

pub const sys = @import("sys.zig");
const rt = @import("rt.zig");
pub const io = @import("io.zig");

pub const os = @import("os.zig"); 

pub var kernel_stack : [4096 * 2] u8 align(4096) = undefined; 
pub var user_stack : @TypeOf(kernel_stack) = undefined; 

pub fn panic(error_message: []const u8, stack: ?*std.builtin.StackTrace, len: ?usize) noreturn {
    _ = stack; 
    _ = len; 
    // todo: lock it... 
    writer.print("\x1b[31;1m{s}\x1b[0m\r\n", .{ error_message }) catch |a| switch (a) {}; 
    sys.shutdown(); 
}

/// The special symbol, describe all applications (would be run) info. 
extern const app_numbers: usize ; 

/// The app application info descriptor, type : unknwon len slice. (The index 0 is the length of the array~ )
pub const app_info = @ptrCast([*]usize, &app_numbers); 

/// An alias of 'app_info'. 
const data_ptr = app_info; 

const log : bool = true; 

const manager = @import("manager.zig"); 

extern fn trap() callconv(.C) void ; 

pub const writer = io.getStdOut().writer(); 

export fn main() callconv(.C) void {

    // initial the .bss segments. 
    rt.emptyBss(); 

    // initial the trap support ~ 
    {
        //set the kernel stack support 
        asm volatile (
            "csrw sscratch, %[val]"
            : : [val] "{t0}" (@ptrToInt(&kernel_stack))
        ); 

        // the addr [XLEN - 1: 2] handle addr ; 
        // mode = 0 : pc to base 
        const base = @ptrToInt(&trap);
        const stvec_val : usize = base & ~@as(usize, 0x3); 

        // comptime {
        //     comptime var val = base & @as(usize, 0x3); 
        //     if (val != 0) {
        //         @compileError("Invalid addr of fn 'trap': not align for 4");
        //     }
        // }

        // set the trap handle now ~ 
        asm volatile (
            \\csrw stvec, %[val]
            : : [val] "{t0}" (stvec_val) 
        ); 

        writer.print("the stack of the kernel: 0x{x}!\nBut My ptr: {x}~ \n", .{ 
            asm ("csrr %[ret], sscratch" : [ret] "={t0},{t1},{t2}" (-> usize)), 
            @ptrToInt(&kernel_stack), 
        }) catch |a| switch (a) {}; 

        asm volatile ( "ebreak" ); 
        // asm volatile ( "ecall" ); 
    }

    if (log) {
        var value = data_ptr[0];
        writer.print("The app count: {}\n", .{ value } ) catch unreachable;
        var i : usize = 0; 
        while (i < value) : (i += 1) {
            writer.print("Index{}: start addr: 0x{x}\n", .{i, data_ptr[i+1]}) catch |v| switch (v) {}; 
        }
    }
    {
        var len = data_ptr[0]; 
        manager.manager = manager.AppManager {
            .app_numbers = len, 
            .current = 0, 
            .app_start = data_ptr[1..(len + 1)],
        };
    }

    // give some log here ~

    // var area = std.heap.ArenaAllocator.init(std.heap.page_allocator); 
    // defer area.deinit(); 
    // const allocator = area.allocator(); 
    // _ = allocator; 

    @import("kernel.zig").main() catch |err| switch (err) {
    }; 
    sys.shutdown(); 
}