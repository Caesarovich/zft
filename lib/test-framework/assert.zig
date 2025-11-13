const std = @import("std");

pub const AssertError = error{
    AssertionFailed,
};

pub const AssertFailureInfo = struct {
    message: []const u8,
    expected: ?[]const u8 = null,
    actual: ?[]const u8 = null,
    file: []const u8 = "",
    line: u32 = 0,
};

var failure_info: ?AssertFailureInfo = null;
// Static buffers to ensure the strings remain valid
var expected_static_buf: [256]u8 = undefined;
var actual_static_buf: [256]u8 = undefined;

pub fn getLastFailure() ?AssertFailureInfo {
    return failure_info;
}

pub fn clearFailure() void {
    failure_info = null;
}

fn setFailure(info: AssertFailureInfo) void {
    failure_info = info;
}

pub fn assert(condition: bool, comptime message: []const u8, src: std.builtin.SourceLocation) AssertError!void {
    if (!condition) {
        setFailure(AssertFailureInfo{
            .message = message,
            .file = src.file,
            .line = src.line,
        });
        return AssertError.AssertionFailed;
    }
}

pub fn assertEqual(comptime T: type, expected: T, actual: T, src: std.builtin.SourceLocation) AssertError!void {
    if (expected != actual) {
        const expected_str = std.fmt.bufPrint(expected_static_buf[0..], "{any}", .{expected}) catch "format error";
        const actual_str = std.fmt.bufPrint(actual_static_buf[0..], "{any}", .{actual}) catch "format error";

        setFailure(AssertFailureInfo{
            .message = "Values not equal",
            .expected = expected_str,
            .actual = actual_str,
            .file = src.file,
            .line = src.line,
        });
        return AssertError.AssertionFailed;
    }
}

pub fn assertNotEqual(comptime T: type, a: T, b: T, src: std.builtin.SourceLocation) AssertError!void {
    if (a == b) {
        var value_buf: [256]u8 = undefined;
        const value_str = std.fmt.bufPrint(value_buf[0..], "{any}", .{a}) catch "format error";

        setFailure(AssertFailureInfo{
            .message = "Values should not be equal",
            .actual = value_str,
            .file = src.file,
            .line = src.line,
        });
        return AssertError.AssertionFailed;
    }
}

pub fn assertNull(comptime T: type, ptr: ?*T, src: std.builtin.SourceLocation) AssertError!void {
    if (ptr != null) {
        setFailure(AssertFailureInfo{
            .message = "Expected null pointer",
            .expected = "null",
            .actual = "non-null pointer",
            .file = src.file,
            .line = src.line,
        });
        return AssertError.AssertionFailed;
    }
}

pub fn assertNotNull(comptime T: type, ptr: ?*T, src: std.builtin.SourceLocation) AssertError!void {
    if (ptr == null) {
        setFailure(AssertFailureInfo{
            .message = "Expected non-null pointer",
            .expected = "non-null pointer",
            .actual = "null",
            .file = src.file,
            .line = src.line,
        });
        return AssertError.AssertionFailed;
    }
}

// Convenience macros that automatically capture source location
pub inline fn expectEqual(comptime T: type, expected: T, actual: T) AssertError!void {
    return assertEqual(T, expected, actual, @src());
}

pub inline fn expectNotEqual(comptime T: type, a: T, b: T) AssertError!void {
    return assertNotEqual(T, a, b, @src());
}

pub inline fn expect(condition: bool, comptime message: []const u8) AssertError!void {
    return assert(condition, message, @src());
}

pub inline fn expectNull(comptime T: type, ptr: ?*T) AssertError!void {
    return assertNull(T, ptr, @src());
}

pub inline fn expectNotNull(comptime T: type, ptr: ?*T) AssertError!void {
    return assertNotNull(T, ptr, @src());
}
