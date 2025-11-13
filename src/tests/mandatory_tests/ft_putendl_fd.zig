const std = @import("std");

const TestFramework = @import("test-framework");
const assert = TestFramework.assert;
const TestCase = TestFramework.tests.TestCase;
const TestSuite = TestFramework.tests.TestSuite;
const TestCaseError = TestFramework.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("unistd.h");
    @cInclude("fcntl.h");
    @cInclude("string.h");
    @cInclude("sys/mman.h");
});

const is_function_defined = function_list.hasFunction("ft_putendl_fd");

fn ft_putendl_fd(s: [*c]u8, fd: c_int) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_putendl_fd(s, fd);
    }
}

fn create_temp_file() !c_int {
    const fd: c_int = try std.posix.memfd_create("zft_test", 0);
    return fd;
}

// Test ft_putendl_fd with normal string
var test_putendl_fd_normal = TestCase{
    .name = "Put normal string with newline to fd",
    .fn_ptr = &test_putendl_fd_normal_fn,
};

fn test_putendl_fd_normal_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "Hello World";
    ft_putendl_fd(@constCast(test_str), fd);

    var buffer: [50]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_len = c.strlen(test_str) + 1; // +1 for newline
    try assert.expect(bytes_read == expected_len, "Expected string length + 1 (newline) bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, c.strlen(test_str)) == 0, "Expected written string to match input");
    try assert.expect(buffer[c.strlen(test_str)] == '\n', "Expected newline at end");
}

// Test ft_putendl_fd with empty string
var test_putendl_fd_empty = TestCase{
    .name = "Put empty string with newline to fd",
    .fn_ptr = &test_putendl_fd_empty_fn,
};

fn test_putendl_fd_empty_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "";
    ft_putendl_fd(@constCast(test_str), fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written (just newline) for empty string");
    try assert.expect(buffer[0] == '\n', "Expected newline character");
}

// Test ft_putendl_fd with null string
var test_putendl_fd_null = TestCase{
    .name = "Put null string with newline to fd",
    .fn_ptr = &test_putendl_fd_null_fn,
};

fn test_putendl_fd_null_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    // This should not crash - behavior depends on implementation
    ft_putendl_fd(null, fd);

    var buffer: [20]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    // Some implementations might write just newline, others might write "(null)\n"
    // We just ensure it doesn't crash
    _ = bytes_read;
}

// Test ft_putendl_fd with string already containing newlines
var test_putendl_fd_with_newlines = TestCase{
    .name = "Put string with existing newlines to fd",
    .fn_ptr = &test_putendl_fd_with_newlines_fn,
};

fn test_putendl_fd_with_newlines_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "Hello\nWorld";
    ft_putendl_fd(@constCast(test_str), fd);

    var buffer: [50]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_len = c.strlen(test_str) + 1; // +1 for additional newline
    try assert.expect(bytes_read == expected_len, "Expected string length + 1 (additional newline) bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, c.strlen(test_str)) == 0, "Expected written string to match input");
    try assert.expect(buffer[c.strlen(test_str)] == '\n', "Expected additional newline at end");
}

// Test ft_putendl_fd with single character
var test_putendl_fd_single_char = TestCase{
    .name = "Put single character with newline to fd",
    .fn_ptr = &test_putendl_fd_single_char_fn,
};

fn test_putendl_fd_single_char_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "A";
    ft_putendl_fd(@constCast(test_str), fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 2, "Expected 2 bytes written (char + newline)");
    try assert.expect(buffer[0] == 'A', "Expected character 'A'");
    try assert.expect(buffer[1] == '\n', "Expected newline character");
}

// Test ft_putendl_fd with long string
var test_putendl_fd_long = TestCase{
    .name = "Put long string with newline to fd",
    .fn_ptr = &test_putendl_fd_long_fn,
};

fn test_putendl_fd_long_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "This is a longer string that tests the function's ability to handle longer inputs and still append the newline correctly.";
    ft_putendl_fd(@constCast(test_str), fd);

    var buffer: [200]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_len = c.strlen(test_str) + 1; // +1 for newline
    try assert.expect(bytes_read == expected_len, "Expected string length + 1 (newline) bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, c.strlen(test_str)) == 0, "Expected written string to match input");
    try assert.expect(buffer[c.strlen(test_str)] == '\n', "Expected newline at end");
}

// Test ft_putendl_fd with special characters
var test_putendl_fd_special = TestCase{
    .name = "Put string with special characters and newline to fd",
    .fn_ptr = &test_putendl_fd_special_fn,
};

fn test_putendl_fd_special_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "Hello\tWorld!";
    ft_putendl_fd(@constCast(test_str), fd);

    var buffer: [50]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_len = c.strlen(test_str) + 1; // +1 for newline
    try assert.expect(bytes_read == expected_len, "Expected string length + 1 (newline) bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, c.strlen(test_str)) == 0, "Expected written string to match input");
    try assert.expect(buffer[c.strlen(test_str)] == '\n', "Expected newline at end");
}

var test_cases = [_]*TestCase{
    &test_putendl_fd_normal,
    &test_putendl_fd_empty,
    &test_putendl_fd_null,
    &test_putendl_fd_with_newlines,
    &test_putendl_fd_single_char,
    &test_putendl_fd_long,
    &test_putendl_fd_special,
};

pub var suite = TestSuite{
    .name = "ft_putendl_fd",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
