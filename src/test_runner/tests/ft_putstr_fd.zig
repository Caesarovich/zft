const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("unistd.h");
    @cInclude("fcntl.h");
    @cInclude("string.h");
});

// Helper function to create a temporary file and return its fd
fn create_temp_file() !c_int {
    const filename = "/tmp/zft_test_XXXXXX";
    const template: [*c]u8 = @ptrCast(@constCast(filename));
    return c.mkstemp(template);
}

// Helper function to read from a file descriptor
fn read_from_fd(fd: c_int, buffer: []u8) !usize {
    // Reset file position to beginning
    _ = c.lseek(fd, 0, c.SEEK_SET);
    const bytes_read = c.read(fd, buffer.ptr, buffer.len - 1);
    if (bytes_read >= 0) {
        buffer[@intCast(bytes_read)] = 0; // null terminate
        return @intCast(bytes_read);
    }
    return error.ReadError;
}

// Test ft_putstr_fd with valid file descriptor
var test_putstr_fd_valid = TestCase{
    .name = "Put string to valid fd",
    .fn_ptr = &test_putstr_fd_valid_fn,
};

fn test_putstr_fd_valid_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return error.TestSkipped;
    defer _ = c.close(fd);

    c.ft_putstr_fd("Hello", fd);

    var buffer: [20]u8 = undefined;
    const bytes_read = read_from_fd(fd, &buffer) catch return error.TestFailed;

    try assert.expect(bytes_read == 5, "Expected 5 bytes written");
    try assert.expect(c.strcmp(&buffer, "Hello") == 0, "Expected string 'Hello'");
}

// Test ft_putstr_fd with empty string
var test_putstr_fd_empty = TestCase{
    .name = "Put empty string to fd",
    .fn_ptr = &test_putstr_fd_empty_fn,
};

fn test_putstr_fd_empty_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return error.TestSkipped;
    defer _ = c.close(fd);

    c.ft_putstr_fd("", fd);

    var buffer: [10]u8 = undefined;
    const bytes_read = read_from_fd(fd, &buffer) catch return error.TestFailed;

    try assert.expect(bytes_read == 0, "Expected 0 bytes written for empty string");
}

// Test ft_putstr_fd with null string
var test_putstr_fd_null = TestCase{
    .name = "Put null string to fd",
    .fn_ptr = &test_putstr_fd_null_fn,
};

fn test_putstr_fd_null_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return error.TestSkipped;
    defer _ = c.close(fd);

    // This should not crash
    c.ft_putstr_fd(null, fd);

    var buffer: [10]u8 = undefined;
    const bytes_read = read_from_fd(fd, &buffer) catch return error.TestFailed;

    try assert.expect(bytes_read == 0, "Expected 0 bytes written for null string");
}

// Test ft_putstr_fd with invalid file descriptor
var test_putstr_fd_invalid = TestCase{
    .name = "Put string to invalid fd",
    .fn_ptr = &test_putstr_fd_invalid_fn,
};

fn test_putstr_fd_invalid_fn(_: std.mem.Allocator) AssertError!void {
    // This should not crash, just fail silently
    c.ft_putstr_fd("Hello", -1);
    // If we reach here without crashing, the test passes
    try assert.expect(true, "Function should handle invalid fd gracefully");
}

// Test ft_putstr_fd with long string
var test_putstr_fd_long = TestCase{
    .name = "Put long string to fd",
    .fn_ptr = &test_putstr_fd_long_fn,
};

fn test_putstr_fd_long_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return error.TestSkipped;
    defer _ = c.close(fd);

    const long_string = "The quick brown fox jumps over the lazy dog";
    c.ft_putstr_fd(long_string, fd);

    var buffer: [100]u8 = undefined;
    const bytes_read = read_from_fd(fd, &buffer) catch return error.TestFailed;

    try assert.expect(bytes_read == 43, "Expected 43 bytes written");
    try assert.expect(c.strcmp(&buffer, long_string) == 0, "Expected long string to match");
}

var test_cases = [_]*TestCase{
    &test_putstr_fd_valid,
    &test_putstr_fd_empty,
    &test_putstr_fd_null,
    &test_putstr_fd_invalid,
    &test_putstr_fd_long,
};

const is_function_defined = function_list.hasFunction("ft_putstr_fd");

pub var suite = TestSuite{
    .name = "ft_putstr_fd",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
