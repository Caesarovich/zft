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
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    exe.root_module.addIncludePath(b.path("includes"));
    exe.root_module.addObjectFile(b.path(libft_archive_path));
    exe.step.dependOn(run_libft_maker_step);

    // ACTIONS
    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the zft executable");
    run_step.dependOn(&run_exe.step);

    b.installArtifact(exe);
}
