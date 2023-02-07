pub const TrapContext = extern struct {
    x: [32] usize, 
    sstatus: usize, 
    sepc: usize, 
}; 

const os = @import("os.zig"); 
const writer = os.writer; 

const app = @import("app.zig"); 

export fn trap_handle(trap_context: *TrapContext) callconv(.C) *TrapContext {
    const scause: usize = asm (
        \\csrr %[r1], scause
        : [r1] "=r" (-> usize) 
    ); 
    const stval : usize = asm (
        \\csrr %[r2], stval
        : [r2] "=r" (-> usize) 
    ); 
    writer.print("\x1b[36;1m[  INFO] scause: {}; stval: 0x{x}\x1b[0m\n", .{ scause, stval }) catch |a| switch (a) {}; 
    writer.print("\x1b[36;1m[  INFO] trap handle {{ cause: {}, value: 0x{x}. }}\x1b[0m\n", .{ scause, stval, }) catch {}; 
    // special case ~ ebreak call 
    if (scause == 3) {
        trap_context.sepc += 2; 
        return trap_context; 
    } else {
        app.manager.run_next_or_exit(); 
    }
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