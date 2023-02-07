const Builder = @import("std").build.Builder;
const builtin = @import("builtin");
const std = @import("std");

const stdout = std.io.getStdOut().writer();

const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) !void {

    const select = try CrossTarget.parse(.{
        .arch_os_abi = "riscv64-freestanding-none", 
        .diagnostics = null, 
    }); 

    try stdout.print("riscv64 os build support. \n", .{} ); 

    if (b.sysroot) |rootdir| {
        try stdout.print("rootdir: {s}\n", .{rootdir});
    } 

    const src = b.addExecutable( std.build.ExecutableOptions {
        .name = "out", 
        .root_source_file = std.Build.FileSource { .path = "src/app.zig" }, 
        .target = select, 
        .optimize = std.builtin.Mode.ReleaseSafe, 
    }); 
    src.addIncludePath("./src"); 
    // set the code model as 'medium', to avoid the limitation of the text lookup. 
    src.code_model = std.builtin.CodeModel.medium;
    // disable LTO, to keep the 'unused' data. 
    src.want_lto = false; 
    // set the link script. 
    src.setLinkerScriptPath(.{ .path = "src/linker.ld" });

    src.install(); 

    const bin = b.addInstallRaw(src, "out.bin", .{ .format = .bin });
    bin.step.dependOn(&src.step);

    const build_bin = b.step("bin", "generate the binary object. "); 
    build_bin.dependOn(&bin.step);
}
