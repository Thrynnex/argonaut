const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const argonaut_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "argonaut",
        .root_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize }),
    });

    exe.root_module.addImport("argonaut", argonaut_module);

    const lib = b.addLibrary(.{
        .name = "argonaut",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);

    const example_basic = b.addExecutable(.{
        .name = "example-basic",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/basic.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "argonaut", .module = argonaut_module },
            },
        }),
    });
    b.installArtifact(example_basic);

    const example_subcommands = b.addExecutable(.{
        .name = "example-subcommands",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/subcommands.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "argonaut", .module = argonaut_module },
            },
        }),
    });
    b.installArtifact(example_subcommands);

    const example_advanced = b.addExecutable(.{
        .name = "example-advanced",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/advanced.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "argonaut", .module = argonaut_module },
            },
        }),
    });
    b.installArtifact(example_advanced);
    
    const example_nested = b.addExecutable(.{
        .name = "example-nested",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/nested_subcommands.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "argonaut", .module = argonaut_module },
            },
        }),
    });
    b.installArtifact(example_nested);

    const run_basic = b.addRunArtifact(example_basic);
    const run_subcommands = b.addRunArtifact(example_subcommands);
    const run_advanced = b.addRunArtifact(example_advanced);
    const run_nested = b.addRunArtifact(example_nested);
    
    if (b.args) |args| {
        run_basic.addArgs(args);
        run_subcommands.addArgs(args);
        run_advanced.addArgs(args);
        run_nested.addArgs(args);
    }

    const run_basic_step = b.step("run-basic", "Run the basic example");
    run_basic_step.dependOn(&run_basic.step);

    const run_subcommands_step = b.step("run-subcommands", "Run the subcommands example");
    run_subcommands_step.dependOn(&run_subcommands.step);

    const run_advanced_step = b.step("run-advanced", "Run the advanced example");
    run_advanced_step.dependOn(&run_advanced.step);
    const run_nested_step = b.step("run-nested", "Run the nested example");
    run_nested_step.dependOn(&run_nested.step);
}
