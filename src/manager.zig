pub const AppManager = struct {
    app_numbers: usize, 
    current: usize, 
    app_start: [] usize, 
    /// assume the next program exists, then run it 
    pub fn run(p: * AppManager, ) !void {
        // run thie program ~ 
        var s = p.app_start[p.current]; 
        _ = s; 
    }
}; 

pub var manager: AppManager = undefined; 

pub const TrapContext = extern struct {
    x: [32] usize, 
    sstatus: usize, 
    sepc: usize, 
}; 

const root = @import("root"); 

export fn trap_handle(trap_context: *TrapContext) callconv(.C) *TrapContext {
    const scause: usize = asm (
        \\csrr %[r1], scause
        : [r1] "={t0}" (-> usize) 
    ); 
    const stval : usize = asm (
        \\csrr %[r2], stval
        : [r2] "={t1}" (-> usize) 
    ); 
    const writer = root.writer; 
    writer.print("scause: {}; stval: 0x{x}\n", .{ scause, stval }) catch |a| switch (a) {}; 
    // _ = .{ scause, stval }; 
    // _ = trap_context;
    // @panic("leaf");
    // special case ~ ebreak call 
    if (scause == 3) {
        trap_context.sepc += 2; 
        return trap_context; 
    } else {
        @panic("todo");
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

extern fn restore( kernel_stack_pointer: ?[*] align(4096) u8 ) callconv(.C) void ; 

// deprecated codes (asm): use macro alt to inline them. 
        // \\sd x5, 5*8(sp)
        // \\sd x6, 6*8(sp)
        // \\sd x7, 7*8(sp)
        // \\sd x8, 8*8(sp)
        // \\sd x9, 9*8(sp)
        // \\sd x10, 10*8(sp)
        // \\sd x11, 11*8(sp)
        // \\sd x12, 12*8(sp)
        // \\sd x13, 13*8(sp)
        // \\sd x14, 14*8(sp)
        // \\sd x15, 15*8(sp)
        // \\sd x16, 16*8(sp)
        // \\sd x17, 17*8(sp)
        // \\sd x18, 18*8(sp)
        // \\sd x19, 19*8(sp)
        // \\sd x20, 20*8(sp)
        // \\sd x21, 21*8(sp)
        // \\sd x22, 22*8(sp)
        // \\sd x23, 23*8(sp)
        // \\sd x24, 24*8(sp)
        // \\sd x25, 25*8(sp)
        // \\sd x26, 26*8(sp)
        // \\sd x27, 27*8(sp)
        // \\sd x28, 28*8(sp)
        // \\sd x29, 29*8(sp)
        // \\sd x30, 30*8(sp)
        // \\sd x31, 31*8(sp)