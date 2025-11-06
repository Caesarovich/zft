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
    @cInclude("sys/mman.h");
});

fn create_temp_file() !c_int {
    const fd: c_int = try std.posix.memfd_create("zft_test", 0);
    return fd;
}

// Test ft_putstr_fd with normal string
var test_putstr_fd_normal = TestCase{
    .name = "Put normal string to fd",
    .fn_ptr = &test_putstr_fd_normal_fn,
};

fn test_putstr_fd_normal_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "Hello World";
    c.ft_putstr_fd(@constCast(test_str), fd);

    var buffer: [50]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    try assert.expect(bytes_read == c.strlen(test_str), "Expected string length bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, bytes_read) == 0, "Expected written string to match input");
}

// Test ft_putstr_fd with empty string
var test_putstr_fd_empty = TestCase{
    .name = "Put empty string to fd",
    .fn_ptr = &test_putstr_fd_empty_fn,
};

fn test_putstr_fd_empty_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "";
    c.ft_putstr_fd(@constCast(test_str), fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    try assert.expect(bytes_read == 0, "Expected 0 bytes written for empty string");
}

// Test ft_putstr_fd with null string
var test_putstr_fd_null = TestCase{
    .name = "Put null string to fd",
    .fn_ptr = &test_putstr_fd_null_fn,
};

fn test_putstr_fd_null_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    // This should not crash - behavior depends on implementation
    c.ft_putstr_fd(null, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    // Some implementations might write nothing, others might write "(null)"
    // We just ensure it doesn't crash
    _ = bytes_read;
}

// Test ft_putstr_fd with string containing special characters
var test_putstr_fd_special_chars = TestCase{
    .name = "Put string with special characters to fd",
    .fn_ptr = &test_putstr_fd_special_chars_fn,
};

fn test_putstr_fd_special_chars_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "Hello\nWorld\t!";
    const expected_len = c.strlen(test_str);
    c.ft_putstr_fd(@constCast(test_str), fd);

    var buffer: [50]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    try assert.expect(bytes_read == expected_len, "Expected string length up to null terminator");
    try assert.expect(c.strncmp(&buffer, test_str, bytes_read) == 0, "Expected written string to match input");
}

// Test ft_putstr_fd with long string
var test_putstr_fd_long = TestCase{
    .name = "Put long string to fd",
    .fn_ptr = &test_putstr_fd_long_fn,
};

fn test_putstr_fd_long_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "This is a longer string that contains multiple words and should test the function's ability to handle strings that are more than just a few characters long.";
    c.ft_putstr_fd(@constCast(test_str), fd);

    var buffer: [200]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    try assert.expect(bytes_read == c.strlen(test_str), "Expected full string length bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, bytes_read) == 0, "Expected written string to match input");
}

// Test ft_putstr_fd with single character string
var test_putstr_fd_single_char = TestCase{
    .name = "Put single character string to fd",
    .fn_ptr = &test_putstr_fd_single_char_fn,
};

fn test_putstr_fd_single_char_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "A";
    c.ft_putstr_fd(@constCast(test_str), fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written");
    try assert.expect(buffer[0] == 'A', "Expected character 'A'");
}

// Test ft_putstr_fd with Unicode/extended ASCII
var test_putstr_fd_extended = TestCase{
    .name = "Put string with extended characters to fd",
    .fn_ptr = &test_putstr_fd_extended_fn,
};

fn test_putstr_fd_extended_fn(_: std.mem.Allocator) AssertError!void {
    const fd = create_temp_file() catch return AssertError.AssertionFailed;
    defer _ = c.close(fd);

    const test_str = "Héllo Wörld!";
    c.ft_putstr_fd(@constCast(test_str), fd);

    var buffer: [50]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return AssertError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return AssertError.AssertionFailed;

    try assert.expect(bytes_read == c.strlen(test_str), "Expected string length bytes written");
    try assert.expect(c.strncmp(&buffer, test_str, bytes_read) == 0, "Expected written string to match input");
}

var test_cases = [_]*TestCase{
    &test_putstr_fd_normal,
    &test_putstr_fd_empty,
    &test_putstr_fd_null,
    &test_putstr_fd_special_chars,
    &test_putstr_fd_long,
    &test_putstr_fd_single_char,
    &test_putstr_fd_extended,
};

const is_function_defined = function_list.hasFunction("ft_putstr_fd");

pub var suite = TestSuite{
    .name = "ft_putstr_fd",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
