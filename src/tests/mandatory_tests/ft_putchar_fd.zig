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

const is_function_defined = function_list.hasFunction("ft_putchar_fd");

fn ft_putchar_fd(char: u8, fd: c_int) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_putchar_fd(char, fd);
    }
}

fn create_temp_file() !c_int {
    const fd: c_int = try std.posix.memfd_create("zft_test", 0);
    return fd;
}

// Test ft_putchar_fd with valid file descriptor
var test_putchar_fd_valid = TestCase{
    .name = "Put char to valid fd",
    .fn_ptr = &test_putchar_fd_valid_fn,
};

fn test_putchar_fd_valid_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putchar_fd('A', fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written");
    try assert.expect(buffer[0] == 'A', "Expected character 'A'");
}

// Test ft_putchar_fd with special characters
var test_putchar_fd_special = TestCase{
    .name = "Put special characters to fd",
    .fn_ptr = &test_putchar_fd_special_fn,
};

fn test_putchar_fd_special_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putchar_fd('\n', fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written");
    try assert.expect(buffer[0] == '\n', "Expected newline character");
}

// Test ft_putchar_fd with zero character
var test_putchar_fd_zero = TestCase{
    .name = "Put zero character to fd",
    .fn_ptr = &test_putchar_fd_zero_fn,
};

fn test_putchar_fd_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putchar_fd(0, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written");
    try assert.expect(buffer[0] == 0, "Expected zero character");
}

// Test with many characters
var test_putchar_fd_many = TestCase{
    .name = "Put many characters to fd",
    .fn_ptr = &test_putchar_fd_many_fn,
};

fn test_putchar_fd_many_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    const chars: [5]u8 = [_]u8{ 'H', 'e', 'l', 'l', 'o' };

    for (chars) |ch| {
        ft_putchar_fd(ch, fd);
    }

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 5, "Expected 5 bytes written");
    for (0..5) |i| {
        try assert.expect(buffer[i] == chars[i], "Expected characters to be written correctly");
    }
}

var test_cases = [_]*TestCase{
    &test_putchar_fd_valid,
    &test_putchar_fd_special,
    &test_putchar_fd_zero,
    &test_putchar_fd_many,
};

pub var suite = TestSuite{
    .name = "ft_putchar_fd",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
