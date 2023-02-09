pub const TrapContext = extern struct {
    x: [32] usize, 
    sstatus: usize, 
    sepc: usize, 
}; 

const os = @import("root").os; 
const std = @import("std"); 

comptime {
    @export(@import("root").trap, std.builtin.ExportOptions {
        .name = "trap_handle",
        .section = ".text", 
    }); 
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

pub extern fn restore( kernel_stack_pointer: * TrapContext ) callconv(.C) noreturn ; 
pub extern fn trap() align(4) callconv(.C) void; 