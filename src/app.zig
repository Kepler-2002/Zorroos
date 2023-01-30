/// The special symbol, describe all applications (would be run) info. 
extern const app_numbers: usize ; 

/// The application info pointer ~ 
const app_info = @ptrCast([*]usize, &app_numbers); 

pub const os = @import("os.zig"); 

pub const writer = os.writer; 

extern fn trap() callconv(.C) void; 

export fn main() callconv(.C) void {
    os.init() catch |a| { @panic(@errorName(a)); }; 

    // the addr [XLEN - 1: 2] handle addr ; 
    // mode = 0 : pc to base 
    const base = @ptrToInt(&trap);
    const stvec_val : usize = base & ~@as(usize, 0x3); 

    // set the trap handle
    asm volatile (
        \\csrw stvec, %[val]
        : : [val] "r" (stvec_val) 
    ); 

    {
        var len = app_info[0]; 
        var offsetptr = @ptrCast([*] [2] usize, app_info + 1); 
        manager = .{
            .app_numbers = len, 
            .app = offsetptr[0..len], 
        }; 
        // check the manager val ~ 
        writer.print("\x1b[36;1m[  INFO] Initial the manager: \n\tnumber: {}\n\tcurrent: {}\n\tapp: {any}\x1b[0m\n",
            .{ manager.app_numbers, manager.current, manager.app }) catch unreachable; 
    }

    manager.run_next_or_exit(); 

}

var manager : Manager = undefined; 

pub const Manager = struct {
    app_numbers: usize, 
    current : usize = 0, 
    app: [] [2] usize, 

    pub fn run_next_or_exit(self: *Manager) noreturn {
        if (self.current == self.app_numbers) {
            // shutdown the computer, when all applications are run done. 
            writer.print("\x1b[32;1m[SYSTEM] All applications are run done. \x1b[0m\n", .{} ) catch unreachable; 
            os.sbi.shutdown(); 
        }
        writer.print("\x1b[36;1m[  INFO] Prepare to run the next application {{ index = {} }} \x1b[0m\n", .{ self.current }) catch unreachable; 
        // when run here, it must be the kernel stack used. 
        // display the kernel stack pointer info: 
        writer.print("\x1b[34;1m[ DEBUG] At Manager.run_next_or_exit debug, now sp: 0x{x}.\x1b[0m\n", .{ 
            asm ( "" : [_] "={sp}" (-> usize) ), 
        }) catch unreachable; 
        @panic("[  TODO] fn: Manager ~ run next or exit ");
    }

}; 

comptime {
    _ = @import("manager.zig"); 
}

comptime {
    asm (
        \\.altmacro 
        \\.macro saverg n
        \\  sd x\n, 8*\n(sp)
        \\.endm 
        \\.align 2 
        \\.section .text
        \\trap: 
        \\csrrw sp, sscratch, sp
        \\addi sp, sp, -34 * 8
        \\sd x1, 8(sp)
        \\sd x3, 3*8(sp)
        \\.set n, 5
        \\.rept 27 
        \\  saverg %n 
        \\  .set n, n+1
        \\.endr 
        \\csrr t0, sstatus
        \\csrr t1, sepc
        \\sd t0, 32*8(sp)
        \\sd t1, 33*8(sp)
        \\csrr t2, sscratch
        \\sd t2, 2*8(sp)
        \\mv a0, sp
        \\call trap_handle

        \\.macro loadrg n
        \\  ld x\n, \n*8(sp)
        \\.endm 
        \\restore: 
        \\  mv sp, a0
        \\  ld t0, 32*8(sp)
        \\  ld t1, 33*8(sp)
        \\  ld t2, 2*8(sp)
        \\  csrw sstatus, t0 
        \\  csrw sepc, t1
        \\  csrw sscratch, t2
        \\  loadrg 1
        \\  loadrg 3
        \\.set n, 5
        \\.rept 27
        \\  loadrg %n
        \\  .set n, n+1
        \\.endr
        \\addi sp, sp, 34*8
        \\csrrw sp, sscratch, sp
        \\sret 
    ); 
}