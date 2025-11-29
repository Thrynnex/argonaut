const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const argonaut_module = b.addModule("argonaut", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "argonaut",
        .root_module = argonaut_module,
        .linkage = .static,
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_module = argonaut_module,
    });
    const run_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);

    const examples = .{
        .{ "example-basic", "examples/basic.zig" },
        .{ "example-subcommands", "examples/subcommands.zig" },
        .{ "example-advanced", "examples/advanced.zig" },
        .{ "example-nested", "examples/nested_subcommands.zig" },
    };

    inline for (examples) |ex| {
        const example_module = b.addModule(ex[0], .{
            .root_source_file = b.path(ex[1]),
            .target = target,
            .optimize = optimize,
        });
        
        const exe = b.addExecutable(.{
            .name = ex[0],
            .root_module = example_module,
        });
        exe.root_module.addImport("argonaut", argonaut_module);

        b.installArtifact(exe);

        const run = b.addRunArtifact(exe);
        if (b.args) |args| run.addArgs(args);

        const step = b.step(ex[0], "Run " ++ ex[0]);
        step.dependOn(&run.step);
    }
}