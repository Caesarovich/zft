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
    @cInclude("limits.h");
});

const is_function_defined = function_list.hasFunction("ft_putnbr_fd");

fn ft_putnbr_fd(n: c_int, fd: c_int) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_putnbr_fd(n, fd);
    }
}

fn create_temp_file() !c_int {
    const fd: c_int = try std.posix.memfd_create("zft_test", 0);
    return fd;
}

// Test ft_putnbr_fd with zero
var test_putnbr_fd_zero = TestCase{
    .name = "Put zero to fd",
    .fn_ptr = &test_putnbr_fd_zero_fn,
};

fn test_putnbr_fd_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(0, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written for zero");
    try assert.expect(buffer[0] == '0', "Expected character '0'");
}

// Test ft_putnbr_fd with positive single digit
var test_putnbr_fd_positive_single = TestCase{
    .name = "Put positive single digit to fd",
    .fn_ptr = &test_putnbr_fd_positive_single_fn,
};

fn test_putnbr_fd_positive_single_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(7, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 1, "Expected 1 byte written for single digit");
    try assert.expect(buffer[0] == '7', "Expected character '7'");
}

// Test ft_putnbr_fd with negative single digit
var test_putnbr_fd_negative_single = TestCase{
    .name = "Put negative single digit to fd",
    .fn_ptr = &test_putnbr_fd_negative_single_fn,
};

fn test_putnbr_fd_negative_single_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(-5, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 2, "Expected 2 bytes written for negative single digit");
    try assert.expect(buffer[0] == '-', "Expected minus sign");
    try assert.expect(buffer[1] == '5', "Expected character '5'");
}

// Test ft_putnbr_fd with positive multi-digit number
var test_putnbr_fd_positive_multi = TestCase{
    .name = "Put positive multi-digit number to fd",
    .fn_ptr = &test_putnbr_fd_positive_multi_fn,
};

fn test_putnbr_fd_positive_multi_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(123, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 3, "Expected 3 bytes written for 123");
    try assert.expect(c.strncmp(&buffer, "123", 3) == 0, "Expected '123'");
}

// Test ft_putnbr_fd with negative multi-digit number
var test_putnbr_fd_negative_multi = TestCase{
    .name = "Put negative multi-digit number to fd",
    .fn_ptr = &test_putnbr_fd_negative_multi_fn,
};

fn test_putnbr_fd_negative_multi_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(-456, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 4, "Expected 4 bytes written for -456");
    try assert.expect(c.strncmp(&buffer, "-456", 4) == 0, "Expected '-456'");
}

// Test ft_putnbr_fd with INT_MAX
var test_putnbr_fd_int_max = TestCase{
    .name = "Put INT_MAX to fd",
    .fn_ptr = &test_putnbr_fd_int_max_fn,
};

fn test_putnbr_fd_int_max_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(c.INT_MAX, fd);

    var buffer: [20]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_str = "2147483647";
    try assert.expect(bytes_read == c.strlen(expected_str), "Expected correct length for INT_MAX");
    try assert.expect(c.strncmp(&buffer, expected_str, bytes_read) == 0, "Expected '2147483647'");
}

// Test ft_putnbr_fd with INT_MIN
var test_putnbr_fd_int_min = TestCase{
    .name = "Put INT_MIN to fd",
    .fn_ptr = &test_putnbr_fd_int_min_fn,
};

fn test_putnbr_fd_int_min_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(c.INT_MIN, fd);

    var buffer: [20]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_str = "-2147483648";
    try assert.expect(bytes_read == c.strlen(expected_str), "Expected correct length for INT_MIN");
    try assert.expect(c.strncmp(&buffer, expected_str, bytes_read) == 0, "Expected '-2147483648'");
}

// Test ft_putnbr_fd with large positive number
var test_putnbr_fd_large_positive = TestCase{
    .name = "Put large positive number to fd",
    .fn_ptr = &test_putnbr_fd_large_positive_fn,
};

fn test_putnbr_fd_large_positive_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(987654321, fd);

    var buffer: [20]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_str = "987654321";
    try assert.expect(bytes_read == c.strlen(expected_str), "Expected correct length for large positive number");
    try assert.expect(c.strncmp(&buffer, expected_str, bytes_read) == 0, "Expected '987654321'");
}

// Test ft_putnbr_fd with large negative number
var test_putnbr_fd_large_negative = TestCase{
    .name = "Put large negative number to fd",
    .fn_ptr = &test_putnbr_fd_large_negative_fn,
};

fn test_putnbr_fd_large_negative_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(-987654321, fd);

    var buffer: [20]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    const expected_str = "-987654321";
    try assert.expect(bytes_read == c.strlen(expected_str), "Expected correct length for large negative number");
    try assert.expect(c.strncmp(&buffer, expected_str, bytes_read) == 0, "Expected '-987654321'");
}

// Test ft_putnbr_fd with number containing zeros
var test_putnbr_fd_zeros = TestCase{
    .name = "Put number with zeros to fd",
    .fn_ptr = &test_putnbr_fd_zeros_fn,
};

fn test_putnbr_fd_zeros_fn(_: std.mem.Allocator) TestCaseError!void {
    const fd = create_temp_file() catch return TestCaseError.AssertionFailed;
    defer _ = c.close(fd);

    ft_putnbr_fd(1001, fd);

    var buffer: [10]u8 = undefined;
    std.posix.lseek_SET(fd, 0) catch return TestCaseError.AssertionFailed;
    const bytes_read = std.posix.read(fd, &buffer) catch return TestCaseError.AssertionFailed;

    try assert.expect(bytes_read == 4, "Expected 4 bytes written for 1001");
    try assert.expect(c.strncmp(&buffer, "1001", 4) == 0, "Expected '1001'");
}

var test_cases = [_]*TestCase{
    &test_putnbr_fd_zero,
    &test_putnbr_fd_positive_single,
    &test_putnbr_fd_negative_single,
    &test_putnbr_fd_positive_multi,
    &test_putnbr_fd_negative_multi,
    &test_putnbr_fd_int_max,
    &test_putnbr_fd_int_min,
    &test_putnbr_fd_large_positive,
    &test_putnbr_fd_large_negative,
    &test_putnbr_fd_zeros,
};

pub var suite = TestSuite{
    .name = "ft_putnbr_fd",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
