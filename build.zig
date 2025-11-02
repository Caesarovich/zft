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

    const libft_path = libft_path_option;
    const libft_archive_path = b.pathJoin(&.{ libft_path, "libft.a" });

    // ANSI MODULE (https://github.com/ziglibs/ansi_term)
    const ansi_module = b.createModule(.{
        .root_source_file = b.path("lib/ansi/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // TESTS MODULE
    const tests_module = b.createModule(.{
        .root_source_file = b.path("lib/tests/main.zig"),
        .target = target,
        .optimize = optimize,
    });

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
    options.addOption([]const u8, "libft-path", libft_path);
    libft_maker.root_module.addOptions("config", options);

    const run_libft_maker = b.addRunArtifact(libft_maker);

    const run_libft_maker_step = b.step("run_libft_maker", "Run the libft_maker executable");
    run_libft_maker_step.dependOn(&run_libft_maker.step);

    var libft_maker_step = b.step("libft_maker", "Build the libft library");
    libft_maker_step.dependOn(&libft_maker.step);

    // MAIN EXECUTABLE
    const exe = b.addExecutable(.{
        .name = "zft",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/test_runner/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "tests", .module = tests_module },
                .{ .name = "ansi", .module = ansi_module },
            },
        }),
    });

    exe.root_module.addIncludePath(b.path("includes"));
    exe.root_module.addObjectFile(b.path(libft_archive_path));
    exe.step.dependOn(run_libft_maker_step);

    // FUNCTION LIST MODULE - Independent module approach
    // Capture nm output at compile time (force rebuild by making it depend on libft file)
    const get_function_list = b.addSystemCommand(&[_][]const u8{ "nm", libft_archive_path, "--defined-only", "--format=just-symbols" });
    // Depend on the run step that actually creates the libft.a file
    get_function_list.step.dependOn(&run_libft_maker.step);
    // Add the libft.a file as an input to force cache invalidation when it changes
    get_function_list.addFileInput(b.path(libft_archive_path));
    const nm_output = get_function_list.captureStdOut();

    // Copy the function list to src directory so our independent module can access it
    const copy_function_list = b.addSystemCommand(&[_][]const u8{"cp"});
    copy_function_list.addFileArg(nm_output);
    copy_function_list.addArg("src/function_list.txt");
    copy_function_list.step.dependOn(&get_function_list.step);
    // Also add libft.a as input to the copy step to ensure proper dependency tracking
    copy_function_list.addFileInput(b.path(libft_archive_path));
    exe.step.dependOn(&copy_function_list.step);

    // Create a module for the function list using our independent module
    const function_list_module = b.createModule(.{
        .root_source_file = b.path("src/function_list.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("function_list", function_list_module);

    const exe_options = b.addOptions();
    exe.root_module.addOptions("config", exe_options);

    // ACTIONS
    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the zft executable");
    run_step.dependOn(&run_exe.step);

    b.installArtifact(exe);
}
