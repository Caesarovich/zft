const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("string.h");
    @cInclude("limits.h");
});

const is_function_defined = function_list.hasFunction("ft_itoa");

fn ft_itoa(n: c_int) [*c]u8 {
    if (comptime is_function_defined) {
        return c.ft_itoa(n);
    } else {
        return null;
    }
}

// Test zero
var test_itoa_zero = TestCase{
    .name = "Convert zero",
    .fn_ptr = &test_itoa_zero_fn,
};

fn test_itoa_zero_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(0);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "0") == 0, "Expected '0'");
        c.free(str);
    }
}

// Test positive number
var test_itoa_positive = TestCase{
    .name = "Convert positive number",
    .fn_ptr = &test_itoa_positive_fn,
};

fn test_itoa_positive_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(42);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "42") == 0, "Expected '42'");
        c.free(str);
    }
}

// Test negative number
var test_itoa_negative = TestCase{
    .name = "Convert negative number",
    .fn_ptr = &test_itoa_negative_fn,
};

fn test_itoa_negative_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(-42);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "-42") == 0, "Expected '-42'");
        c.free(str);
    }
}

// Test INT_MAX
var test_itoa_int_max = TestCase{
    .name = "Convert INT_MAX",
    .fn_ptr = &test_itoa_int_max_fn,
};

fn test_itoa_int_max_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(c.INT_MAX);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "2147483647") == 0, "Expected '2147483647'");
        c.free(str);
    }
}

// Test INT_MIN
var test_itoa_int_min = TestCase{
    .name = "Convert INT_MIN",
    .fn_ptr = &test_itoa_int_min_fn,
};

fn test_itoa_int_min_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(c.INT_MIN);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "-2147483648") == 0, "Expected '-2147483648'");
        c.free(str);
    }
}

// Test single digit positive
var test_itoa_single_digit_pos = TestCase{
    .name = "Convert single digit positive",
    .fn_ptr = &test_itoa_single_digit_pos_fn,
};

fn test_itoa_single_digit_pos_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(7);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "7") == 0, "Expected '7'");
        c.free(str);
    }
}

// Test single digit negative
var test_itoa_single_digit_neg = TestCase{
    .name = "Convert single digit negative",
    .fn_ptr = &test_itoa_single_digit_neg_fn,
};

fn test_itoa_single_digit_neg_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(-3);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "-3") == 0, "Expected '-3'");
        c.free(str);
    }
}

// Test large positive number
var test_itoa_large_positive = TestCase{
    .name = "Convert large positive number",
    .fn_ptr = &test_itoa_large_positive_fn,
};

fn test_itoa_large_positive_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(123456789);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "123456789") == 0, "Expected '123456789'");
        c.free(str);
    }
}

// Test large negative number
var test_itoa_large_negative = TestCase{
    .name = "Convert large negative number",
    .fn_ptr = &test_itoa_large_negative_fn,
};

fn test_itoa_large_negative_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(-987654321);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "-987654321") == 0, "Expected '-987654321'");
        c.free(str);
    }
}

// Test number with trailing zeros in decimal (should not be present)
var test_itoa_multiples_of_ten = TestCase{
    .name = "Convert multiples of ten",
    .fn_ptr = &test_itoa_multiples_of_ten_fn,
};

fn test_itoa_multiples_of_ten_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_itoa(1000);
    try assert.expect(result != null, "ft_itoa should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "1000") == 0, "Expected '1000'");
        c.free(str);
    }
}

var test_cases = [_]*TestCase{
    &test_itoa_zero,
    &test_itoa_positive,
    &test_itoa_negative,
    &test_itoa_int_max,
    &test_itoa_int_min,
    &test_itoa_single_digit_pos,
    &test_itoa_single_digit_neg,
    &test_itoa_large_positive,
    &test_itoa_large_negative,
    &test_itoa_multiples_of_ten,
};

pub var suite = TestSuite{
    .name = "ft_itoa",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
