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

const is_function_defined = function_list.hasFunction("ft_strlen");

fn ft_strlen(str: [*c]const u8) usize {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_strlen(str);
    }
}

var test_empty_string = TestCase{
    .name = "Empty string",
    .fn_ptr = &test_empty_string_fn,
};

var test_normal_string = TestCase{
    .name = "Normal string",
    .fn_ptr = &test_normal_string_fn,
};

var test_long_string = TestCase{
    .name = "Long string",
    .fn_ptr = &test_long_string_fn,
};

fn test_empty_string_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_strlen("") == 0, "Expected empty string to have length 0");
}

fn test_normal_string_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_strlen("Hello") == 5, "Expected \"Hello\" to have length 5");
}

fn test_long_string_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_strlen("abcdefghijklmnopqrstuvwxyz") == 26, "Expected alphabet string to have length 26");
}

var test_cases = [_]*TestCase{ &test_empty_string, &test_normal_string, &test_long_string };

pub var suite = TestSuite{
    .name = "ft_strlen",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
