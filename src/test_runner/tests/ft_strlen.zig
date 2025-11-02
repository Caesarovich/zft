const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

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

fn test_empty_string_fn() AssertError!void {
    try assert.expect(c.ft_strlen("") == 0, "Expected empty string to have length 0");
}

fn test_normal_string_fn() AssertError!void {
    try assert.expect(c.ft_strlen("Hello") == 5, "Expected \"Hello\" to have length 5");
}

fn test_long_string_fn() AssertError!void {
    try assert.expect(c.ft_strlen("abcdefghijklmnopqrstuvwxyz") == 26, "Expected alphabet string to have length 26");
}

const test_cases = [_]*TestCase{ &test_empty_string, &test_normal_string, &test_long_string };

pub const suite = TestSuite{
    .name = "ft_strlen",
    .cases = test_cases[0..],
};
