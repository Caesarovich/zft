const std = @import("std");
const ansi = @import("ansi");

const tests = @import("tests");

const test_collections = @import("tests/main.zig");

const config = @import("config");

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
        try stdout.writeAll(" - Skipped\n");
        return;
    }

    try stdout.writeAll("\n");

    try ansi.format.resetStyle(stdout);

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
                try ansi.format.updateStyle(stdout, .{ .foreground = .Red, .font_style = .{ .bold = true } }, .{});
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

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const write_buffer = allocator.alloc(u8, 1024) catch unreachable;
    defer allocator.free(write_buffer);
    var stdout_write = std.fs.File.stdout().writer(write_buffer);
    const stdout = &stdout_write.interface;

    var base_collection = test_collections.base_test_collection;

    base_collection.run(allocator);

    for (base_collection.suites) |suite| {
        try print_test_suite_results(stdout, suite.*);
    }

    try stdout.flush();
}
