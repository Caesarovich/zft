const std = @import("std");

pub fn build(b: *std.Build) void {
    // OPTIONS
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libft_path_option = b.option(
        []const u8,
        "libft-path",
        "Path to the libft directory",
    ) orelse "libft";

    const bonus_option = b.option(
        bool,
        "bonus",
        "Include bonus tests",
    ) orelse false;

    const llvm_option = b.option(
        bool,
        "use-llvm",
        "Use LLVM backend for compilation",
    ) orelse false;

    const libft_archive_path = b.pathJoin(&.{ libft_path_option, "libft.a" });

    // ANSI MODULE (https://github.com/ziglibs/ansi_term)
    const ansi_module = b.createModule(.{
        .root_source_file = b.path("lib/ansi/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // TERMSIZE MODULE (https://github.com/softprops/zig-termsize)
    const termsize_module = b.createModule(.{
        .root_source_file = b.path("lib/termsize/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // UNIT TESTS FRAMEWORK
    const test_framework_module = b.createModule(.{
        .root_source_file = b.path("lib/test-framework/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // UNIT TESTS
    const tests_module = b.createModule(.{
        .root_source_file = b.path("src/tests/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "test-framework", .module = test_framework_module },
        },
    });

    tests_module.addIncludePath(b.path("includes"));
    tests_module.addObjectFile(b.path(libft_archive_path));

    // LIBFT_MAKER
    const libft_maker = b.addExecutable(.{
        .name = "libft_maker",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/libft_maker/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "ansi", .module = ansi_module },
            },
        }),
    });

    const options = b.addOptions();
    options.addOption([]const u8, "libft-path", libft_path_option);
    options.addOption(bool, "bonus", bonus_option);
    libft_maker.root_module.addOptions("config", options);

    const run_libft_maker = b.addRunArtifact(libft_maker);

    const run_libft_maker_step = b.step("run_libft_maker", "Run the libft_maker executable");
    run_libft_maker_step.dependOn(&run_libft_maker.step);

    var libft_maker_step = b.step("libft_maker", "Build the libft library");
    libft_maker_step.dependOn(&libft_maker.step);

    // FUNCTION LIST MODULE
    const get_function_list = b.addSystemCommand(&[_][]const u8{ "nm", libft_archive_path, "--defined-only", "--format=just-symbols" });
    get_function_list.step.dependOn(&run_libft_maker.step);
    get_function_list.addFileInput(b.path(libft_archive_path));
    const nm_output = get_function_list.captureStdOut();

    const copy_function_list = b.addSystemCommand(&[_][]const u8{"cp"});
    copy_function_list.addFileArg(nm_output);
    copy_function_list.addArg("src/function_list.txt");
    copy_function_list.step.dependOn(&get_function_list.step);
    copy_function_list.addFileInput(b.path(libft_archive_path));

    const function_list_module = b.createModule(.{
        .root_source_file = b.path("src/function_list.zig"),
        .target = target,
        .optimize = optimize,
    });

    tests_module.addImport("function_list", function_list_module);

    // MAIN EXECUTABLE
    const exe = b.addExecutable(.{
        .name = "zft",
        .use_llvm = llvm_option,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/test_runner/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "test-framework", .module = test_framework_module },
                .{ .name = "ansi", .module = ansi_module },
                .{ .name = "termsize", .module = termsize_module },
                .{ .name = "tests", .module = tests_module },
            },
        }),
    });

    exe.step.dependOn(run_libft_maker_step);
    exe.step.dependOn(&copy_function_list.step);

    const exe_options = b.addOptions();
    exe_options.addOption([]const u8, "libft-path", libft_path_option);
    exe_options.addOption(bool, "bonus", bonus_option);
    exe.root_module.addOptions("config", exe_options);

    // ACTIONS
    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the zft executable");
    run_step.dependOn(&run_exe.step);

    b.installArtifact(exe);
}
