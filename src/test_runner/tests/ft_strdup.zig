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

// ft_strdup

// Test basic string duplication
var test_strdup_basic = TestCase{
    .name = "Basic string duplication",
    .fn_ptr = &test_strdup_basic_fn,
};

fn test_strdup_basic_fn() AssertError!void {
    var original: [*c]const u8 = "Hello, World!";
    var duplicated: ?[*c]const u8 = c.ft_strdup(original);

    if (duplicated) |d| {
        try assert.expect(std.mem.eql(u8, std.mem.span(original), std.mem.span(d)), "Duplicated string should match the original");
        c.free(@constCast(d));
    } else {
        try assert.expect(false, "ft_strdup returned null pointer");
    }

    original = "Zig is awesome!";
    duplicated = c.ft_strdup(original);

    if (duplicated) |d| {
        try assert.expect(std.mem.eql(u8, std.mem.span(original), std.mem.span(d)), "Duplicated string should match the original");
        c.free(@constCast(d));
    } else {
        try assert.expect(false, "ft_strdup returned null pointer");
    }
}

// Test duplication of empty string
var test_strdup_empty = TestCase{
    .name = "Empty string duplication",
    .fn_ptr = &test_strdup_empty_fn,
};

fn test_strdup_empty_fn() AssertError!void {
    const original: [*c]const u8 = "";
    const duplicated: ?[*c]const u8 = c.ft_strdup(original);

    if (duplicated) |d| {
        try assert.expect(std.mem.eql(u8, std.mem.span(original), std.mem.span(d)), "Duplicated string should match the original empty string");
        c.free(@constCast(d));
    } else {
        try assert.expect(false, "ft_strdup returned null pointer for empty string");
    }
}

const test_cases = [_]*TestCase{
    &test_strdup_basic,
    &test_strdup_empty,
};

const is_function_defined = function_list.hasFunction("ft_strdup");

pub const suite = TestSuite{
    .name = "ft_strdup",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
