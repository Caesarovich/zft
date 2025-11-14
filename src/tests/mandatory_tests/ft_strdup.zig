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

const is_function_defined = function_list.hasFunction("ft_strdup");

fn ft_strdup(s: [*c]const u8) [*c]u8 {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_strdup(s);
    }
}

// Test basic string duplication
var test_strdup_basic = TestCase{
    .name = "Basic string duplication",
    .fn_ptr = &test_strdup_basic_fn,
};

fn test_strdup_basic_fn(_: std.mem.Allocator) TestCaseError!void {
    var original: [*c]const u8 = "Hello, World!";
    var duplicated: ?[*c]const u8 = ft_strdup(original);

    if (duplicated) |d| {
        try assert.expect(std.mem.eql(u8, std.mem.span(original), std.mem.span(d)), "Duplicated string should match the original");
        c.free(@constCast(d));
    } else {
        try assert.expect(false, "ft_strdup returned null pointer");
    }

    original = "Zig is awesome!";
    duplicated = ft_strdup(original);

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

fn test_strdup_empty_fn(_: std.mem.Allocator) TestCaseError!void {
    const original: [*c]const u8 = "";
    const duplicated: ?[*c]const u8 = ft_strdup(original);

    if (duplicated) |d| {
        try assert.expect(std.mem.eql(u8, std.mem.span(original), std.mem.span(d)), "Duplicated string should match the original empty string");
        c.free(@constCast(d));
    } else {
        try assert.expect(false, "ft_strdup returned null pointer for empty string");
    }
}

// Test with NULL input
var test_strdup_null = TestCase{
    .name = "NULL string duplication",
    .speculative = true,
    .fn_ptr = &test_strdup_null_fn,
};

fn test_strdup_null_fn(_: std.mem.Allocator) TestCaseError!void {
    const duplicated = ft_strdup(null);

    try assert.expect(duplicated == null, "ft_strdup should return null when input is null");
}

var test_cases = [_]*TestCase{
    &test_strdup_basic,
    &test_strdup_empty,
    &test_strdup_null,
};

pub var suite = TestSuite{
    .name = "ft_strdup",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
