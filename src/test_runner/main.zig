const std = @import("std");
const ansi = @import("ansi");
const termsize = @import("termsize");

const TestFramework = @import("test-framework");
const TestSuite = TestFramework.tests.TestSuite;
const TestResult = TestFramework.tests.TestResult;
const TestCollection = TestFramework.tests.TestCollection;

const test_collections = @import("tests");

const config = @import("config");
const bonus_enabled = config.bonus;

pub const TestCounts = struct {
    total: usize,
    passed: usize,
    failed: usize,
    skipped: usize,

    pub fn add(self: TestCounts, other: TestCounts) TestCounts {
        return TestCounts{
            .total = self.total + other.total,
            .passed = self.passed + other.passed,
            .failed = self.failed + other.failed,
            .skipped = self.skipped + other.skipped,
        };
    }
};

fn print_test_suite_results(stdout: *std.io.Writer, suite: TestSuite) !TestCounts {
    var counts: TestCounts = .{ .total = 0, .passed = 0, .failed = 0, .skipped = 0 };

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
        // All cases considered skipped for this suite
        var skipped_count: usize = 0;
        for (suite.cases) |_| skipped_count += 1;
        counts.skipped += skipped_count;
        counts.total += skipped_count;

        try stdout.writeAll(" - Skipped");
        try ansi.format.resetStyle(stdout);
        try stdout.writeAll("\n");
        return counts;
    }

    try ansi.format.resetStyle(stdout);
    try stdout.writeAll("\n");

    for (suite.cases) |test_case| {
        counts.total += 1;
        switch (test_case.result) {
            TestResult.pass => {
                counts.passed += 1;
                try ansi.format.updateStyle(stdout, .{ .foreground = .Green }, .{});
                try stdout.writeAll(" ✔ ");
                try ansi.format.resetStyle(stdout);

                try ansi.format.updateStyle(stdout, .{ .font_style = .{ .dim = true } }, .{});
                try stdout.print("{s}\n", .{test_case.name});
                try ansi.format.resetStyle(stdout);
            },
            TestResult.fail, TestResult.segfault => |r| {
                counts.failed += 1;
                try ansi.format.updateStyle(stdout, .{
                    .foreground = if (test_case.speculative) .Yellow else .Red,
                }, .{});
                try stdout.print(" ✕ {s}{s}{s}\n", .{ test_case.name, if (test_case.speculative) " (speculative)" else "", if (r == .segfault) " [⚠️ SEGFAULT]" else "" });
                try ansi.format.resetStyle(stdout);

                if (test_case.fail_info) |info| {
                    // If the test case has an optional description, show it first
                    if (test_case.description) |desc| {
                        try ansi.format.updateStyle(stdout, .{ .font_style = .{ .dim = true } }, .{});
                        try stdout.print("   {s}\n", .{desc});
                        try ansi.format.resetStyle(stdout);
                    }

                    // Main failure message
                    try stdout.print("   {s}\n", .{info.message});

                    // Show expected/actual values when available
                    if (info.expected) |expected|
                        try stdout.print("   Expected: {s}\n", .{expected});
                    if (info.actual) |actual|
                        try stdout.print("   Received: {s}\n", .{actual});

                    // Show source location of the failing assertion when provided
                    if (info.file.len != 0) {
                        try stdout.print("   at {s}:{d}\n", .{ info.file, info.line });
                    }
                }
            },
            else => {},
        }
    }

    return counts;
}

fn print_test_collection_title(allocator: std.mem.Allocator, stdout: *std.io.Writer, collection: *TestCollection) !void {
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

fn run_test_collection(allocator: std.mem.Allocator, writer: *std.io.Writer, collection: *TestCollection) !TestCounts {
    try print_test_collection_title(allocator, writer, collection);
    collection.run(allocator);

    var total_counts: TestCounts = .{ .total = 0, .passed = 0, .failed = 0, .skipped = 0 };

    for (collection.suites) |suite| {
        const suite_counts = try print_test_suite_results(writer, suite.*);
        total_counts = total_counts.add(suite_counts);
    }

    return total_counts;
}

fn print_final_report(allocator: std.mem.Allocator, stdout: *std.io.Writer, counts: TestCounts) !void {
    const pass_percent: usize = if (counts.total == 0) 0 else (counts.passed * 100) / counts.total;

    const headers = [_][]const u8{ "Passed", "Failed", "Skipped", "Total", "Pass%" };

    // Prepare value strings
    const val_passed = try std.fmt.allocPrint(allocator, "{d}", .{counts.passed});
    defer allocator.free(val_passed);
    const val_failed = try std.fmt.allocPrint(allocator, "{d}", .{counts.failed});
    defer allocator.free(val_failed);
    const val_skipped = try std.fmt.allocPrint(allocator, "{d}", .{counts.skipped});
    defer allocator.free(val_skipped);
    const val_total = try std.fmt.allocPrint(allocator, "{d}", .{counts.total});
    defer allocator.free(val_total);
    const val_passpct = try std.fmt.allocPrint(allocator, "{d}%", .{pass_percent});
    defer allocator.free(val_passpct);

    const values = [_][]const u8{ val_passed, val_failed, val_skipped, val_total, val_passpct };

    // Compute column widths
    var col_widths: [5]usize = .{ 0, 0, 0, 0, 0 };
    for (0..headers.len) |i| {
        const h = headers[i];
        const hl = h.len;
        const vl = values[i].len;
        const w = if (hl > vl) hl else vl;
        col_widths[i] = w + 2; // padding
    }

    // Table width (including borders)
    var table_width: usize = 1;
    for (col_widths) |w| table_width += w + 1;

    // Helper to write a border like +-----+----+ ...
    var border = try std.ArrayList(u8).initCapacity(allocator, table_width);
    defer border.deinit(allocator);
    try border.append(allocator, '+');
    for (col_widths) |w| {
        for (0..w) |_| try border.append(allocator, '-');
        try border.append(allocator, '+');
    }

    // Title
    const title = " Test Report ";
    const inner_width = table_width - 2;
    const title_pad_total = if (inner_width > title.len) inner_width - title.len else 0;
    const title_pad_left = title_pad_total / 2;
    const title_pad_right = title_pad_total - title_pad_left;

    try stdout.writeAll("\n");
    try stdout.writeAll(border.items);
    try stdout.writeAll("\n|");
    for (0..title_pad_left) |_| try stdout.writeAll(" ");
    try ansi.format.updateStyle(stdout, .{ .foreground = .Magenta, .font_style = .{ .bold = true } }, .{});
    try stdout.writeAll(title);
    try ansi.format.resetStyle(stdout);
    for (0..title_pad_right) |_| try stdout.writeAll(" ");
    try stdout.writeAll("|\n");

    try stdout.writeAll(border.items);
    try stdout.writeAll("\n");

    // Header row
    try stdout.writeAll("|");
    for (0..headers.len) |i| {
        const h = headers[i];
        const w = col_widths[i];
        const pad_total = w - h.len;
        const pad_left = pad_total / 2;
        const pad_right = pad_total - pad_left;
        for (0..pad_left) |_| try stdout.writeAll(" ");
        try stdout.writeAll(h);
        for (0..pad_right) |_| try stdout.writeAll(" ");
        try stdout.writeAll("|");
    }
    try stdout.writeAll("\n");

    // Header separator
    try stdout.writeAll(border.items);
    try stdout.writeAll("\n");

    // Values row (with colors)
    try stdout.writeAll("|");
    for (0..values.len) |i| {
        const v = values[i];
        const w = col_widths[i];
        const pad_total = w - v.len;
        const pad_left = pad_total / 2;
        const pad_right = pad_total - pad_left;

        for (0..pad_left) |_| try stdout.writeAll(" ");

        if (i == 0) {
            try ansi.format.updateStyle(stdout, .{ .foreground = .Green }, .{});
            try stdout.writeAll(v);
            try ansi.format.resetStyle(stdout);
        } else if (i == 1) {
            try ansi.format.updateStyle(stdout, .{ .foreground = .Red }, .{});
            try stdout.writeAll(v);
            try ansi.format.resetStyle(stdout);
        } else if (i == 2) {
            try ansi.format.updateStyle(stdout, .{ .foreground = .{ .Grey = 128 } }, .{});
            try stdout.writeAll(v);
            try ansi.format.resetStyle(stdout);
        } else if (i == 4) {
            try ansi.format.updateStyle(stdout, .{ .font_style = .{ .bold = true } }, .{});
            try stdout.writeAll(v);
            try ansi.format.resetStyle(stdout);
        } else {
            try stdout.writeAll(v);
        }

        for (0..pad_right) |_| try stdout.writeAll(" ");
        try stdout.writeAll("|");
    }
    try stdout.writeAll("\n");

    // Bottom border
    try stdout.writeAll(border.items);
    try stdout.writeAll("\n\n");
}

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    const write_buffer = allocator.alloc(u8, 1024) catch unreachable;
    defer allocator.free(write_buffer);

    var stdout_write = std.fs.File.stdout().writer(write_buffer);
    const stdout = &stdout_write.interface;
    defer stdout.flush() catch {};

    var total_report: TestCounts = .{ .total = 0, .passed = 0, .failed = 0, .skipped = 0 };

    const base_counts = try run_test_collection(allocator, stdout, &test_collections.mandatory_test_collection);
    total_report = total_report.add(base_counts);

    if (bonus_enabled) {
        const bonus_counts = try run_test_collection(allocator, stdout, &test_collections.bonus_test_collection);
        total_report = total_report.add(bonus_counts);
    }

    try print_final_report(allocator, stdout, total_report);
}
