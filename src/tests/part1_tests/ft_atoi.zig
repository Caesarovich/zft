const std = @import("std");

const TestFramework = @import("test-framework");
const assert = TestFramework.assert;
const TestCase = TestFramework.tests.TestCase;
const TestSuite = TestFramework.tests.TestSuite;
const TestCaseError = TestFramework.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

const is_function_defined = function_list.hasFunction("ft_atoi");

fn ft_atoi(str: [*c]const u8) c_int {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_atoi(str);
    }
}

// ft_atoi

// Test basic positive number conversion
var test_atoi_positive = TestCase{
    .name = "Atoi positive number",
    .fn_ptr = &test_atoi_positive_fn,
};

fn test_atoi_positive_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "1";
    var result = ft_atoi(str);
    try assert.expect(result == 1, "ft_atoi should convert '1' to 1");

    str = "9";
    result = ft_atoi(str);
    try assert.expect(result == 9, "ft_atoi should convert '9' to 9");

    str = "42";
    result = ft_atoi(str);
    try assert.expect(result == 42, "ft_atoi should convert '42' to 42");

    str = "12345";
    result = ft_atoi(str);
    try assert.expect(result == 12345, "ft_atoi should convert '12345' to 12345");
}

// Test negative number conversion
var test_atoi_negative = TestCase{
    .name = "Atoi negative number",
    .fn_ptr = &test_atoi_negative_fn,
};

fn test_atoi_negative_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "-1";
    var result = ft_atoi(str);
    try assert.expect(result == -1, "ft_atoi should convert '-1' to -1");

    str = "-9";
    result = ft_atoi(str);
    try assert.expect(result == -9, "ft_atoi should convert '-9' to -9");

    str = "-42";
    result = ft_atoi(str);
    try assert.expect(result == -42, "ft_atoi should convert '-42' to -42");

    str = "-12345";
    result = ft_atoi(str);
    try assert.expect(result == -12345, "ft_atoi should convert '-12345' to -12345");
}

// Test zero conversion
var test_atoi_zero = TestCase{
    .name = "Atoi zero",
    .fn_ptr = &test_atoi_zero_fn,
};

fn test_atoi_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "0";
    var result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should convert '0' to 0");

    str = "-0";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should convert '-0' to 0");
}

// Test leading whitespace handling
var test_atoi_leading_whitespace = TestCase{
    .name = "Atoi leading whitespace",
    .fn_ptr = &test_atoi_leading_whitespace_fn,
};

fn test_atoi_leading_whitespace_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "   42";
    var result = ft_atoi(str);
    try assert.expect(result == 42, "ft_atoi should ignore leading whitespace and convert '   42' to 42");

    str = "\t\n  -42";
    result = ft_atoi(str);
    try assert.expect(result == -42, "ft_atoi should ignore leading whitespace and convert '\\t\\n  -42' to -42");
}

// Test multiple signs handling
var test_atoi_multiple_signs = TestCase{
    .name = "Atoi multiple signs",
    .fn_ptr = &test_atoi_multiple_signs_fn,
};

fn test_atoi_multiple_signs_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "--42";
    var result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '--42'");

    str = "++42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '++42'");

    str = "-+42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '-+42'");

    str = "+-42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '+-42'");
}

// Test Multiple signs with leading whitespace
var test_atoi_multiple_signs_whitespace = TestCase{
    .name = "Atoi multiple signs with leading whitespace",
    .fn_ptr = &test_atoi_multiple_signs_whitespace_fn,
};

fn test_atoi_multiple_signs_whitespace_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "   --42";
    var result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '   --42'");

    str = "\t\n ++42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '\\t\\n ++42'");

    str = "  -+42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '  -+42'");

    str = " +-42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for ' + -42'");
}

// Test with invalid leading characters

var test_atoi_invalid_leading = TestCase{
    .name = "Atoi invalid leading characters",
    .fn_ptr = &test_atoi_invalid_leading_fn,
};

fn test_atoi_invalid_leading_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "abc42";
    var result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for 'abc42'");

    str = "!!-42";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '!!-42'");

    str = "  - 123";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '  - 123'");
}

// Test with invalid trailing characters
var test_atoi_invalid_trailing = TestCase{
    .name = "Atoi invalid trailing characters",
    .fn_ptr = &test_atoi_invalid_trailing_fn,
};

fn test_atoi_invalid_trailing_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "42abc";
    var result = ft_atoi(str);
    try assert.expect(result == 42, "ft_atoi should convert '42abc' to 42");

    str = "-42!!";
    result = ft_atoi(str);
    try assert.expect(result == -42, "ft_atoi should convert '-42!!' to -42");

    str = "123 456";
    result = ft_atoi(str);
    try assert.expect(result == 123, "ft_atoi should convert '123 456' to 123");
}

// Test with empty string
var test_atoi_empty_string = TestCase{
    .name = "Atoi empty string",
    .fn_ptr = &test_atoi_empty_string_fn,
};

fn test_atoi_empty_string_fn(_: std.mem.Allocator) TestCaseError!void {
    const str: [*c]const u8 = "";
    const result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for empty string");
}

// Test with only invalid characters
var test_atoi_only_invalid = TestCase{
    .name = "Atoi only invalid characters",
    .fn_ptr = &test_atoi_only_invalid_fn,
};

fn test_atoi_only_invalid_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "!!!";
    var result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for '!!!'");

    str = "   ";
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for string with only whitespace");
}

// Test limits

var test_atoi_limits = TestCase{
    .name = "Atoi limits",
    .fn_ptr = &test_atoi_limits_fn,
};

fn test_atoi_limits_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "2147483647"; // INT_MAX
    var result = ft_atoi(str);
    try assert.expect(result == 2147483647, "ft_atoi should convert '2147483647' to INT_MAX");

    str = "-2147483648"; // INT_MIN
    result = ft_atoi(str);
    try assert.expect(result == -2147483648, "ft_atoi should convert '-2147483648' to INT_MIN");
}

// Test with overflow bigger than int but smaller than long long
var test_atoi_overflow = TestCase{
    .name = "Atoi overflow beyond int",
    .speculative = true,
    .fn_ptr = &test_atoi_overflow_fn,
};

fn test_atoi_overflow_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "9223372036854775805"; // LLONG_MAX - 2
    var result = ft_atoi(str);
    try assert.expect(result == -3, "ft_atoi should overflow and return -3 for overflow beyond int");

    str = "-9223372036854775806"; // LLONG_MIN + 2
    result = ft_atoi(str);
    try assert.expect(result == 2, "ft_atoi should overflow and return 2 for underflow beyond int");
}

// Test with overflow bigger than long long
var test_atoi_overflow_long_long = TestCase{
    .name = "Atoi overflow beyond long long",
    .speculative = true,
    .fn_ptr = &test_atoi_overflow_long_long_fn,
};

fn test_atoi_overflow_long_long_fn(_: std.mem.Allocator) TestCaseError!void {
    var str: [*c]const u8 = "92233720368547758079223372036854775807"; // way beyond LLONG_MAX
    var result = ft_atoi(str);
    try assert.expect(result == -1, "ft_atoi should return -1 for extreme overflow beyond long long");

    str = "-92233720368547758089223372036854775808"; // way beyond LLONG_MIN
    result = ft_atoi(str);
    try assert.expect(result == 0, "ft_atoi should return 0 for extreme underflow beyond long long");
}

var test_cases = [_]*TestCase{
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
    &test_atoi_overflow,
    &test_atoi_overflow_long_long,
};

pub var suite = TestSuite{
    .name = "ft_atoi",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
