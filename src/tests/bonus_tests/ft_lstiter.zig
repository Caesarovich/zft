const std = @import("std");

const TestFramework = @import("test-framework");
const assert = TestFramework.assert;
const TestCase = TestFramework.tests.TestCase;
const TestSuite = TestFramework.tests.TestSuite;
const TestCaseError = TestFramework.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("string.h");
    @cInclude("stdlib.h");
});

const is_function_defined = function_list.hasFunction("ft_lstiter");

fn ft_lstiter(lst: ?*c.t_list, f: ?*const fn (?*anyopaque) callconv(.c) void) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_lstiter(lst, f);
    }
}

// Helper function that tracks calls and modifies content
var iter_call_count: u32 = 0;
var iter_sum: u32 = 0;

fn count_and_sum_function(content: ?*anyopaque) callconv(.c) void {
    iter_call_count += 1;
    if (content) |ptr| {
        const value = @as(*u32, @ptrCast(@alignCast(ptr)));
        iter_sum += value.*;
    }
}

// Function that doubles the content value
fn double_function(content: ?*anyopaque) callconv(.c) void {
    if (content) |ptr| {
        const value = @as(*u32, @ptrCast(@alignCast(ptr)));
        value.* *= 2;
    }
}

// Function that converts lowercase to uppercase
fn to_upper_function(content: ?*anyopaque) callconv(.c) void {
    if (content) |ptr| {
        const ch = @as(*u8, @ptrCast(ptr));
        if (ch.* >= 'a' and ch.* <= 'z') {
            ch.* = ch.* - 32;
        }
    }
}

// Function that just counts calls (for null content test)
var null_content_call_count: u32 = 0;
fn count_calls_function(content: ?*anyopaque) callconv(.c) void {
    _ = content;
    null_content_call_count += 1;
}

// Test iterating over an empty list
var test_lstiter_empty = TestCase{
    .name = "Iterate over empty list",
    .fn_ptr = &test_lstiter_empty_fn,
};

fn test_lstiter_empty_fn(_: std.mem.Allocator) TestCaseError!void {
    iter_call_count = 0;
    iter_sum = 0;

    ft_lstiter(null, &count_and_sum_function);

    try assert.expect(iter_call_count == 0, "Expected function not to be called for empty list");
    try assert.expect(iter_sum == 0, "Expected sum to remain 0");
}

// Test iterating over a single node list
var test_lstiter_single = TestCase{
    .name = "Iterate over single node list",
    .fn_ptr = &test_lstiter_single_fn,
};

fn test_lstiter_single_fn(_: std.mem.Allocator) TestCaseError!void {
    iter_call_count = 0;
    iter_sum = 0;

    var value: u32 = 42;
    var node: c.t_list = .{
        .content = &value,
        .next = null,
    };

    ft_lstiter(&node, &count_and_sum_function);

    try assert.expect(iter_call_count == 1, "Expected function to be called once");
    try assert.expect(iter_sum == 42, "Expected sum to be 42");
}

// Test iterating over multiple nodes
var test_lstiter_multiple = TestCase{
    .name = "Iterate over multiple nodes",
    .fn_ptr = &test_lstiter_multiple_fn,
};

fn test_lstiter_multiple_fn(_: std.mem.Allocator) TestCaseError!void {
    iter_call_count = 0;
    iter_sum = 0;

    var value1: u32 = 10;
    var value2: u32 = 20;
    var value3: u32 = 30;

    var node3: c.t_list = .{
        .content = &value3,
        .next = null,
    };

    var node2: c.t_list = .{
        .content = &value2,
        .next = &node3,
    };

    var node1: c.t_list = .{
        .content = &value1,
        .next = &node2,
    };

    ft_lstiter(&node1, &count_and_sum_function);

    try assert.expect(iter_call_count == 3, "Expected function to be called three times");
    try assert.expect(iter_sum == 60, "Expected sum to be 60");
}

// Test iterating and modifying content
var test_lstiter_modify = TestCase{
    .name = "Iterate and modify content",
    .fn_ptr = &test_lstiter_modify_fn,
};

fn test_lstiter_modify_fn(_: std.mem.Allocator) TestCaseError!void {
    var value1: u32 = 5;
    var value2: u32 = 10;
    var value3: u32 = 15;

    var node3: c.t_list = .{
        .content = &value3,
        .next = null,
    };

    var node2: c.t_list = .{
        .content = &value2,
        .next = &node3,
    };

    var node1: c.t_list = .{
        .content = &value1,
        .next = &node2,
    };

    ft_lstiter(&node1, &double_function);

    try assert.expect(value1 == 10, "Expected first value to be doubled to 10");
    try assert.expect(value2 == 20, "Expected second value to be doubled to 20");
    try assert.expect(value3 == 30, "Expected third value to be doubled to 30");
}

// Test iterating over string content
var test_lstiter_string = TestCase{
    .name = "Iterate over string content",
    .fn_ptr = &test_lstiter_string_fn,
};

fn test_lstiter_string_fn(_: std.mem.Allocator) TestCaseError!void {
    var ch1: u8 = 'a';
    var ch2: u8 = 'b';
    var ch3: u8 = 'c';

    var node3: c.t_list = .{
        .content = &ch3,
        .next = null,
    };

    var node2: c.t_list = .{
        .content = &ch2,
        .next = &node3,
    };

    var node1: c.t_list = .{
        .content = &ch1,
        .next = &node2,
    };

    ft_lstiter(&node1, &to_upper_function);

    try assert.expect(ch1 == 'A', "Expected 'a' to become 'A'");
    try assert.expect(ch2 == 'B', "Expected 'b' to become 'B'");
    try assert.expect(ch3 == 'C', "Expected 'c' to become 'C'");
}

// Test iterating over nodes with null content
var test_lstiter_null_content = TestCase{
    .name = "Iterate over nodes with null content",
    .speculative = true,
    .fn_ptr = &test_lstiter_null_content_fn,
};

fn test_lstiter_null_content_fn(_: std.mem.Allocator) TestCaseError!void {
    null_content_call_count = 0;

    var node2: c.t_list = .{
        .content = null,
        .next = null,
    };

    var node1: c.t_list = .{
        .content = null,
        .next = &node2,
    };

    ft_lstiter(&node1, &count_calls_function);

    try assert.expect(null_content_call_count == 2, "Expected function to be called twice even with null content");
}

var test_cases = [_]*TestCase{
    &test_lstiter_empty,
    &test_lstiter_single,
    &test_lstiter_multiple,
    &test_lstiter_modify,
    &test_lstiter_string,
    &test_lstiter_null_content,
};

pub var suite = TestSuite{
    .name = "ft_lstiter",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
