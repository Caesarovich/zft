const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

// ft_atoi

// Test basic positive number conversion
var test_atoi_positive = TestCase{
    .name = "Atoi positive number",
    .fn_ptr = &test_atoi_positive_fn,
};

fn test_atoi_positive_fn() AssertError!void {
    var str: [*c]const u8 = "1";
    var result = c.ft_atoi(str);
    try assert.expect(result == 1, "ft_atoi should convert '1' to 1");

    str = "9";
    result = c.ft_atoi(str);
    try assert.expect(result == 9, "ft_atoi should convert '9' to 9");

    str = "42";
    result = c.ft_atoi(str);
    try assert.expect(result == 42, "ft_atoi should convert '42' to 42");

    str = "12345";
    result = c.ft_atoi(str);
    try assert.expect(result == 12345, "ft_atoi should convert '12345' to 12345");
}

// Test negative number conversion
var test_atoi_negative = TestCase{
    .name = "Atoi negative number",
    .fn_ptr = &test_atoi_negative_fn,
};

fn test_atoi_negative_fn() AssertError!void {
    var str: [*c]const u8 = "-1";
    var result = c.ft_atoi(str);
    try assert.expect(result == -1, "ft_atoi should convert '-1' to -1");

    str = "-9";
    result = c.ft_atoi(str);
    try assert.expect(result == -9, "ft_atoi should convert '-9' to -9");

    str = "-42";
    result = c.ft_atoi(str);
    try assert.expect(result == -42, "ft_atoi should convert '-42' to -42");

    str = "-12345";
    result = c.ft_atoi(str);
    try assert.expect(result == -12345, "ft_atoi should convert '-12345' to -12345");
}

// Test zero conversion
var test_atoi_zero = TestCase{
    .name = "Atoi zero",
    .fn_ptr = &test_atoi_zero_fn,
};

fn test_atoi_zero_fn() AssertError!void {
    var str: [*c]const u8 = "0";
    var result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should convert '0' to 0");

    str = "-0";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should convert '-0' to 0");
}

// Test leading whitespace handling
var test_atoi_leading_whitespace = TestCase{
    .name = "Atoi leading whitespace",
    .fn_ptr = &test_atoi_leading_whitespace_fn,
};

fn test_atoi_leading_whitespace_fn() AssertError!void {
    var str: [*c]const u8 = "   42";
    var result = c.ft_atoi(str);
    try assert.expect(result == 42, "ft_atoi should ignore leading whitespace and convert '   42' to 42");

    str = "\t\n  -42";
    result = c.ft_atoi(str);
    try assert.expect(result == -42, "ft_atoi should ignore leading whitespace and convert '\\t\\n  -42' to -42");
}

// Test multiple signs handling
var test_atoi_multiple_signs = TestCase{
    .name = "Atoi multiple signs",
    .fn_ptr = &test_atoi_multiple_signs_fn,
};

fn test_atoi_multiple_signs_fn() AssertError!void {
    var str: [*c]const u8 = "--42";
    var result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '--42'");

    str = "++42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '++42'");

    str = "-+42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '-+42'");

    str = "+-42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '+-42'");
}

// Test Multiple signs with leading whitespace
var test_atoi_multiple_signs_whitespace = TestCase{
    .name = "Atoi multiple signs with leading whitespace",
    .fn_ptr = &test_atoi_multiple_signs_whitespace_fn,
};

fn test_atoi_multiple_signs_whitespace_fn() AssertError!void {
    var str: [*c]const u8 = "   --42";
    var result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '   --42'");

    str = "\t\n ++42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '\\t\\n ++42'");

    str = "  -+42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '  -+42'");

    str = " +-42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for ' + -42'");
}

// Test with invalid leading characters

var test_atoi_invalid_leading = TestCase{
    .name = "Atoi invalid leading characters",
    .fn_ptr = &test_atoi_invalid_leading_fn,
};

fn test_atoi_invalid_leading_fn() AssertError!void {
    var str: [*c]const u8 = "abc42";
    var result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for 'abc42'");

    str = "!!-42";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '!!-42'");

    str = "  - 123";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '  - 123'");
}

// Test with invalid trailing characters
var test_atoi_invalid_trailing = TestCase{
    .name = "Atoi invalid trailing characters",
    .fn_ptr = &test_atoi_invalid_trailing_fn,
};

fn test_atoi_invalid_trailing_fn() AssertError!void {
    var str: [*c]const u8 = "42abc";
    var result = c.ft_atoi(str);
    try assert.expect(result == 42, "ft_atoi should convert '42abc' to 42");

    str = "-42!!";
    result = c.ft_atoi(str);
    try assert.expect(result == -42, "ft_atoi should convert '-42!!' to -42");

    str = "123 456";
    result = c.ft_atoi(str);
    try assert.expect(result == 123, "ft_atoi should convert '123 456' to 123");
}

// Test with empty string
var test_atoi_empty_string = TestCase{
    .name = "Atoi empty string",
    .fn_ptr = &test_atoi_empty_string_fn,
};

fn test_atoi_empty_string_fn() AssertError!void {
    const str: [*c]const u8 = "";
    const result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for empty string");
}

// Test with only invalid characters
var test_atoi_only_invalid = TestCase{
    .name = "Atoi only invalid characters",
    .fn_ptr = &test_atoi_only_invalid_fn,
};

fn test_atoi_only_invalid_fn() AssertError!void {
    var str: [*c]const u8 = "!!!";
    var result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '!!!'");

    str = "   ";
    result = c.ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for string with only whitespace");
}

// Test limits

var test_atoi_limits = TestCase{
    .name = "Atoi limits",
    .fn_ptr = &test_atoi_limits_fn,
};

fn test_atoi_limits_fn() AssertError!void {
    var str: [*c]const u8 = "2147483647"; // INT_MAX
    var result = c.ft_atoi(str);
    try assert.expect(result == 2147483647, "ft_atoi should convert '2147483647' to INT_MAX");

    str = "-2147483648"; // INT_MIN
    result = c.ft_atoi(str);
    try assert.expect(result == -2147483648, "ft_atoi should convert '-2147483648' to INT_MIN");
}

const test_cases = [_]*TestCase{
    &test_atoi_positive,
    &test_atoi_negative,
    &test_atoi_zero,
    &test_atoi_leading_whitespace,
    &test_atoi_multiple_signs,
    &test_atoi_multiple_signs_whitespace,
    &test_atoi_invalid_leading,
    &test_atoi_invalid_trailing,
    &test_atoi_empty_string,
    &test_atoi_only_invalid,
    &test_atoi_limits,
};

const is_function_defined = function_list.hasFunction("ft_atoi");

pub const suite = TestSuite{
    .name = "ft_atoi",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
