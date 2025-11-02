const std = @import("std");

// This module provides access to the libft function list captured at compile time
// The function list data is provided by the build system through a generated file

pub const function_list_raw = @embedFile("function_list.txt");

// Parse and provide utility functions for the function list
pub fn getFunctionCount() usize {
    @setEvalBranchQuota(5000);
    var count: usize = 0;
    var iterator = std.mem.splitScalar(u8, function_list_raw, '\n');
    while (iterator.next()) |line| {
        if (line.len > 0) count += 1;
    }
    return count;
}

pub fn hasFunction(name: []const u8) bool {
    @setEvalBranchQuota(5000);
    var iterator = std.mem.splitScalar(u8, function_list_raw, '\n');
    while (iterator.next()) |line| {
        if (std.mem.eql(u8, std.mem.trim(u8, line, " \t\r\n"), name)) {
            return true;
        }
    }
    return false;
}

pub fn forEachFunction(comptime Context: type, context: Context, callback: fn (Context, []const u8, usize) void) void {
    var i: usize = 0;
    var iterator = std.mem.splitScalar(u8, function_list_raw, '\n');
    while (iterator.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len > 0) {
            callback(context, trimmed, i);
            i += 1;
        }
    }
}

pub fn printFunctionList(writer: anytype) !void {
    const count = getFunctionCount();
    try writer.print("Libft functions ({} total):\n", .{count});
    var i: usize = 1;
    var iterator = std.mem.splitScalar(u8, function_list_raw, '\n');
    while (iterator.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len > 0) {
            try writer.print("  {}: {s}\n", .{ i, trimmed });
            i += 1;
        }
    }
}

// Get function at specific index (returns null if out of bounds)
pub fn getFunctionAt(index: usize) ?[]const u8 {
    var i: usize = 0;
    var iterator = std.mem.splitScalar(u8, function_list_raw, '\n');
    while (iterator.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len > 0) {
            if (i == index) return trimmed;
            i += 1;
        }
    }
    return null;
}

// Check if a function starts with a specific prefix
pub fn hasFunctionWithPrefix(prefix: []const u8) bool {
    var iterator = std.mem.splitScalar(u8, function_list_raw, '\n');
    while (iterator.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len >= prefix.len and std.mem.eql(u8, trimmed[0..prefix.len], prefix)) {
            return true;
        }
    }
    return false;
}
