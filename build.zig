const Builder = @import("std").build.Builder;
const builtin = @import("builtin");
const std = @import("std");

const plat = "riscv64 in qemu"; 

const stdout = std.io.getStdOut().writer();

const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) !void {

    var diags: CrossTarget.ParseOptions.Diagnostics = .{};
    const select = CrossTarget.parse(.{
        .arch_os_abi = "riscv64-freestanding-none", 
        .diagnostics = &diags,
    }) catch unreachable; 

    try stdout.print("正在编译" ++ plat ++ "\n", .{});

    if (b.sysroot) |rootdir| {
        try stdout.print("rootdir: {s}\n", .{rootdir});
    } 

    // .1，共三层依赖关系：1生成elf，2复制到./zig-out/bin/目录，3最终的build step(shell中可见)
    const src = b.addExecutable("out", "src/app.zig");

    src.addIncludePath("./src"); 

    src.setTarget(select); 

    src.setBuildMode(std.builtin.Mode.ReleaseSafe);

    // src.want_lto = false; // 禁用lto，因为启用则llvm连接时会把本该放到bin文件中特定数据段的的全局常量忽略，当成未引用的数据给优化掉！

    src.code_model = .medium;

    src.setLinkerScriptPath(.{ .path = "src/linker.ld" });

    //.2
    const elf = b.addInstallArtifact(src);
    elf.step.dependOn(&src.step);

    const bin = b.addInstallRaw(src, "out.bin", .{ .format = .bin });
    bin.step.dependOn(&src.step);

    //.3
    const build_elf = b.step("elf", "编译为qemu可加载的elf kernel");
    build_elf.dependOn(&elf.step);

    const build_bin = b.step("bin", "生成bin文件");
    build_bin.dependOn(&bin.step);

    b.default_step = build_elf;

    // // const qemu_bin_step = b.step("qemubin", "Generate binary file to be flashed");
    // // qemu_bin_step.dependOn(&qemu_bin.step);

    // //.3
    // const qemu_step = b.step("qemu", "编译为qemu可加载的elf kernel");
    // qemu_step.dependOn(&cp2outdir.step);
    // // qemu_step.dependOn(&qemu_bin.step);

    // // 指定默认生成哪个目标
    // // b.default_step.dependOn(&src.step);
    // // b.default_step = bin_step;
    // b.default_step = qemu_step;

}
