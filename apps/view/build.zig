const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = std.Target.Cpu.Arch.riscv64, 
            .os_tag = std.Target.Os.Tag.freestanding, 
            .abi = .none, 
        }, 
    });

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("view", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    exe.addPackage(.{
        .name = "kernel-sys", 
        .source = .{ .path = "/home/cutiedeng/zig-core/src/sys.zig" }, 
    }); 

    const bin = b.addInstallRaw(exe, "view.bin", .{ .format = .bin }); 

    const call_bin = b.step("bin", "build a raw binary file"); 
    call_bin.dependOn(&bin.step); 
}
