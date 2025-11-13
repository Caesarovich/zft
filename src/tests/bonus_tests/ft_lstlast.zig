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

const is_function_defined = function_list.hasFunction("ft_lstlast");

fn ft_lstlast(lst: ?*c.t_list) ?*c.t_list {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_lstlast(lst);
    }
}

// Test ft_lstlast with empty list
var test_lstlast_empty = TestCase{
    .name = "Last node of empty list",
    .fn_ptr = &test_lstlast_empty_fn,
};

fn test_lstlast_empty_fn(_: std.mem.Allocator) TestCaseError!void {
    const last = ft_lstlast(null);
    try assert.expect(last == null, "Expected last node of empty list to be null");
}

// Test ft_lstlast with single node list
var test_lstlast_single = TestCase{
    .name = "Last node of single node list",
    .fn_ptr = &test_lstlast_single_fn,
};

fn test_lstlast_single_fn(_: std.mem.Allocator) TestCaseError!void {
    const value: u8 = 42;
    var lst: c.t_list = .{
        .content = @constCast(&value),
        .next = null,
    };

    const last = ft_lstlast(&lst);
    try assert.expect(last != null, "Expected last node to be non-null");
    try assert.expect(last == &lst, "Expected last node to be the only node");

    if (last) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.*.content)).* == value, "Expected content to be 42");
        try assert.expect(node.*.next == null, "Expected next to be null");
    }
}

// Test ft_lstlast with multiple node list
var test_lstlast_multiple = TestCase{
    .name = "Last node of multiple node list",
    .fn_ptr = &test_lstlast_multiple_fn,
};

fn test_lstlast_multiple_fn(_: std.mem.Allocator) TestCaseError!void {
    const value1: u8 = 1;
    const value2: u8 = 2;
    const value3: u8 = 3;

    var node3: c.t_list = .{
        .content = @constCast(&value3),
        .next = null,
    };

    var node2: c.t_list = .{
        .content = @constCast(&value2),
        .next = &node3,
    };

    var lst: c.t_list = .{
        .content = @constCast(&value1),
        .next = &node2,
    };

    const last = ft_lstlast(&lst);
    try assert.expect(last != null, "Expected last node to be non-null");
    try assert.expect(last == &node3, "Expected last node to be the third node");

    if (last) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.*.content)).* == value3, "Expected content to be 3");
        try assert.expect(node.*.next == null, "Expected next to be null");
    }
}

// Test ft_lstlast with large list
var test_lstlast_large = TestCase{
    .name = "Last node of large list",
    .fn_ptr = &test_lstlast_large_fn,
};

fn test_lstlast_large_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const list_size = 100;
    var head: ?*c.t_list = null;
    var current: ?*c.t_list = null;
    var last_node: ?*c.t_list = null;

    // Create a large list
    for (0..list_size) |i| {
        const new_node = allocator.create(c.t_list) catch return error.OutOfMemory;
        const value = allocator.create(usize) catch return error.OutOfMemory;
        value.* = i;

        new_node.* = .{
            .content = value,
            .next = null,
        };

        if (head == null) {
            head = new_node;
            current = head;
        } else {
            current.?.next = new_node;
            current = new_node;
        }
        last_node = new_node;
    }

    const found_last = ft_lstlast(@constCast(head));
    try assert.expect(found_last != null, "Expected last node to be found");
    try assert.expect(found_last == last_node, "Expected found last node to match the actual last node");

    if (found_last) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.*.content)).* == (list_size - 1), "Expected content to be the last value");
        try assert.expect(node.*.next == null, "Expected next to be null");
    }
}

var test_cases = [_]*TestCase{
    &test_lstlast_empty,
    &test_lstlast_single,
    &test_lstlast_multiple,
    &test_lstlast_large,
};

pub var suite = TestSuite{
    .name = "ft_lstlast",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
