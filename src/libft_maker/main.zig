////////////////////////////////////////////////
// This program builds the libft library by running its Makefile.
// It is intended to be executed as part of the build process for the main zft executable.
////////////////////////////////////////////////
const config = @import("config");
const std = @import("std");
const fs = std.fs;
const process = std.process;
const ansi = @import("ansi");

const libft_path = config.@"libft-path";
const libft_bonus = config.bonus;

pub const LibftMakerError = error{
    ReadLibftDirFailed,
    MakefileNotFound,
    MakefileExecutionFailed,
    ArchiveCreationFailed,
};

pub fn make_libft(allocator: std.mem.Allocator) LibftMakerError!void {
    var libft_dir = fs.cwd().openDir(libft_path, .{}) catch return LibftMakerError.ReadLibftDirFailed;
    defer libft_dir.close();

    const makefile_file = libft_dir.openFile("Makefile", .{}) catch return LibftMakerError.MakefileNotFound;
    defer makefile_file.close();

    const make_argv = &[_][]const u8{ "make", if (libft_bonus) "bonus" else "all" };
    var make_process = process.Child.init(make_argv, allocator);
    make_process.cwd_dir = libft_dir;
    make_process.stdout_behavior = .Ignore;

    const result = make_process.spawnAndWait() catch return LibftMakerError.MakefileExecutionFailed;
    if (result.Exited != 0) {
        return LibftMakerError.MakefileExecutionFailed;
    }

    // Sleep for a short duration to ensure file system consistency
    std.Thread.sleep(100_000_000);

    const libft_a_file = libft_dir.openFile("libft.a", .{}) catch return LibftMakerError.ArchiveCreationFailed;
    defer libft_a_file.close();
}

fn printMessage(writer: *std.io.Writer, comptime fmt: []const u8, args: anytype, style: ?ansi.style.Style) !void {
    try ansi.format.updateStyle(writer, .{ .foreground = .Blue, .font_style = .{ .bold = true } }, null);
    try writer.writeAll("[ZFT] ");
    try ansi.format.updateStyle(writer, style orelse .{ .foreground = .Default }, null);
    try writer.print(fmt, args);
    try ansi.format.resetStyle(writer);
    try writer.flush();
}

fn printErrorMessage(writer: *std.io.Writer, comptime fmt: []const u8, args: anytype) !void {
    try ansi.format.updateStyle(writer, .{ .foreground = .Red, .font_style = .{ .bold = true } }, null);
    try writer.writeAll("[ZFT] ");
    try ansi.format.updateStyle(writer, .{
        .foreground = .Red,
    }, null);
    try writer.print(fmt, args);
    try ansi.format.resetStyle(writer);
    try writer.flush();
}

pub fn main() void {
    const allocator = std.heap.page_allocator;

    const write_buffer = allocator.alloc(u8, 1024) catch unreachable;
    defer allocator.free(write_buffer);
    var stdout_write = std.fs.File.stdout().writer(write_buffer);
    const stdout = &stdout_write.interface;

    printMessage(stdout, "Building libft located at: {s}\n", .{libft_path}, null) catch unreachable;
    make_libft(allocator) catch |err| {
        printErrorMessage(stdout, "Error while making libft: ", .{}) catch unreachable;
        switch (err) {
            LibftMakerError.ReadLibftDirFailed => std.debug.print("Could not read libft directory ({s})\n", .{libft_path}),
            LibftMakerError.MakefileNotFound => std.debug.print("Makefile not found in libft directory ({s}/Makefile)\n", .{libft_path}),
            LibftMakerError.MakefileExecutionFailed => std.debug.print("Failed to execute Makefile\n", .{}),
            LibftMakerError.ArchiveCreationFailed => std.debug.print("Failed to create libft.a archive\n", .{}),
        }
        std.process.exit(1);
    };
    printMessage(stdout, "Successfully built libft!\n", .{}, .{ .foreground = .Green }) catch unreachable;
}
