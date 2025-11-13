const std = @import("std");

// This module provides access to the libft function list captured at compile time
// The function list data is provided by the build system through a generated file

pub const function_list_raw = @embedFile("function_list.txt");

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
