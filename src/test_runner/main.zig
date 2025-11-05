const std = @import("std");
const ansi = @import("ansi");
const termsize = @import("termsize");

const tests = @import("tests");
const test_collections = @import("tests/main.zig");

const config = @import("config");
const bonus_enabled = config.bonus;

fn print_test_suite_results(stdout: *std.io.Writer, suite: tests.tests.TestSuite) !void {
    try ansi.format.resetStyle(stdout);

    const title_color: ansi.style.Color = switch (suite.result) {
        .skipped => .{ .Grey = 128 },
        .success => .Green,
        .failed => .Red,
    };

    try ansi.format.updateStyle(stdout, .{ .background = title_color, .foreground = .Black, .font_style = .{ .bold = true } }, .{});

    switch (suite.result) {
        .skipped => try stdout.print("‣ {s}", .{suite.name}),
        .success => try stdout.print("✔ {s}", .{suite.name}),
        .failed => try stdout.print("✘ {s}", .{suite.name}),
    }

    if (suite.result == .skipped) {
        try stdout.writeAll(" - Skipped");
        try ansi.format.resetStyle(stdout);
        try stdout.writeAll("\n");
        return;
    }

    try ansi.format.resetStyle(stdout);
    try stdout.writeAll("\n");

    for (suite.cases) |test_case| {
        switch (test_case.result) {
            tests.tests.TestResult.pass => {
                try ansi.format.updateStyle(stdout, .{ .foreground = .Green }, .{});
                try stdout.writeAll(" ✔ ");
                try ansi.format.resetStyle(stdout);

                try ansi.format.updateStyle(stdout, .{ .font_style = .{ .dim = true } }, .{});
                try stdout.print("{s}\n", .{test_case.name});
                try ansi.format.resetStyle(stdout);
            },
            tests.tests.TestResult.fail => {
                try ansi.format.updateStyle(stdout, .{
                    .foreground = .Red,
                }, .{});
                try stdout.print(" ✕ {s}\n", .{test_case.name});
                try ansi.format.resetStyle(stdout);

                if (test_case.fail_info) |info| {
                    try stdout.print("   {s}\n", .{info.message});
                    if (info.expected) |expected|
                        try stdout.print("   Expected: {s}\n", .{expected});
                    if (info.actual) |actual|
                        try stdout.print("   Received: {s}\n", .{actual});
                }
            },
            tests.tests.TestResult.segfault => {
                try ansi.format.updateStyle(stdout, .{ .foreground = .Red }, .{});
                try stdout.writeAll(" ⚠️ ");
                try ansi.format.resetStyle(stdout);
                try ansi.format.updateStyle(stdout, .{ .font_style = .{ .bold = true } }, .{});
                try stdout.print("{s} [SEGFAULT]\n", .{test_case.name});
                try ansi.format.resetStyle(stdout);
            },
            else => {},
        }
    }
}

fn print_test_collection_title(allocator: std.mem.Allocator, stdout: *std.io.Writer, collection: *tests.tests.TestCollection) !void {
    const size = try termsize.termSize(std.fs.File.stdout());
    const width = if (size) |s| s.width else 80;
    const delimiter_width = (width - collection.name.len - 2) / 2;

    var delimiter = try std.ArrayList(u8).initCapacity(allocator, width);
    defer delimiter.deinit(allocator);

    for (0..delimiter_width) |_| {
        _ = try delimiter.append(allocator, '=');
    }

    try stdout.writeAll("\n");
    try ansi.format.updateStyle(stdout, .{ .font_style = .{ .dim = true } }, .{});
    try stdout.writeAll(delimiter.items);

    try ansi.format.updateStyle(stdout, .{
        .foreground = .Blue,
        .font_style = .{
            .bold = true,
        },
    }, .{ .font_style = .{ .dim = true } });

    try stdout.print(" {s} ", .{collection.name});
    try ansi.format.resetStyle(stdout);

    try ansi.format.updateStyle(stdout, .{ .font_style = .{ .dim = true } }, .{});
    try stdout.writeAll(delimiter.items);

    try stdout.writeAll("\n\n");
}

fn run_test_collection(allocator: std.mem.Allocator, writer: *std.io.Writer, collection: *tests.tests.TestCollection) !void {
    try print_test_collection_title(allocator, writer, collection);
    collection.run(allocator);

    for (collection.suites) |suite| {
        try print_test_suite_results(writer, suite.*);
    }
}

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const write_buffer = allocator.alloc(u8, 1024) catch unreachable;
    defer allocator.free(write_buffer);

    var stdout_write = std.fs.File.stdout().writer(write_buffer);
    const stdout = &stdout_write.interface;
    defer stdout.flush() catch {};

    run_test_collection(allocator, stdout, &test_collections.base_test_collection) catch unreachable;

    if (bonus_enabled) {
        run_test_collection(allocator, stdout, &test_collections.bonus_test_collection) catch unreachable;
    }
}
