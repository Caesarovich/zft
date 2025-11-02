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

// Test with equal strings
var test_equal_strings = TestCase{
    .name = "Equal strings",
    .fn_ptr = &test_equal_strings_fn,
};

fn test_equal_strings_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("Hello", "Hello", 5) == 0, "Expected equal strings to return 0");
}

// Test with first string less than second
var test_first_less = TestCase{
    .name = "First string less than second",
    .fn_ptr = &test_first_less_fn,
};

fn test_first_less_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("Apple", "Banana", 5) < 0, "Expected 'Apple' to be less than 'Banana'");
}

// Test with first string greater than second
var test_first_greater = TestCase{
    .name = "First string greater than second",
    .fn_ptr = &test_first_greater_fn,
};

fn test_first_greater_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("Orange", "Grape", 5) > 0, "Expected 'Orange' to be greater than 'Grape'");
}

// Test with n less than string lengths
var test_n_less_than_length = TestCase{
    .name = "n less than string lengths",
    .fn_ptr = &test_n_less_than_length_fn,
};

fn test_n_less_than_length_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("HelloWorld", "HelloZebra", 5) == 0, "Expected first 5 characters to be equal");
    try assert.expect(c.ft_strncmp("HelloWorld", "HelloZebra", 7) < 0, "Expected 'HelloWo' to be less than 'HelloZe'");
}

// Test with n greater than string lengths
var test_n_greater_than_length = TestCase{
    .name = "n greater than string lengths",
    .fn_ptr = &test_n_greater_than_length_fn,
};

fn test_n_greater_than_length_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("Short", "Shorter", 10) < 0, "Expected 'Short' to be less than 'Shorter'");
    try assert.expect(c.ft_strncmp("Longer", "Long", 10) > 0, "Expected 'Longer' to be greater than 'Long'");
}

// Test with empty strings
var test_empty_strings = TestCase{
    .name = "Empty strings",
    .fn_ptr = &test_empty_strings_fn,
};

fn test_empty_strings_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("", "", 5) == 0, "Expected two empty strings to be equal");
    try assert.expect(c.ft_strncmp("", "NonEmpty", 5) < 0, "Expected empty string to be less than non-empty string");
    try assert.expect(c.ft_strncmp("NonEmpty", "", 5) > 0, "Expected non-empty string to be greater than empty string");
}

// Test with zero n
var test_zero_n = TestCase{
    .name = "Zero n",
    .fn_ptr = &test_zero_n_fn,
};

fn test_zero_n_fn() AssertError!void {
    try assert.expect(c.ft_strncmp("Anything", "Different", 0) == 0, "Expected comparison with n=0 to return 0");
}

const test_cases = [_]*TestCase{
    &test_equal_strings,
    &test_first_less,
    &test_first_greater,
    &test_n_less_than_length,
    &test_n_greater_than_length,
    &test_empty_strings,
    &test_zero_n,
};

const is_function_defined = function_list.hasFunction("ft_strncmp");

pub const suite = TestSuite{
    .name = "ft_strncmp",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
