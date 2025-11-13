const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;
const TestCaseError = tests.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("string.h");
    @cInclude("stdlib.h");
});

const is_function_defined = function_list.hasFunction("ft_lstadd_front");

fn ft_lstadd_front(lst: ?*?*c.t_list, new: ?*c.t_list) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_lstadd_front(lst, new);
    }
}

// Test adding a node to the front of an empty list
var test_lstadd_front_to_empty = TestCase{
    .name = "Add node to front of empty list",
    .fn_ptr = &test_lstadd_front_to_empty_fn,
};

fn test_lstadd_front_to_empty_fn(_: std.mem.Allocator) AssertError!void {
    const value: u8 = 42;
    var lst: ?*c.t_list = null;
    var new_node: c.t_list = .{
        .content = @constCast(&value),
        .next = null,
    };

    ft_lstadd_front(&lst, &new_node);

    try assert.expect(lst != null, "List should not be null after adding node");
    try assert.expect(lst == &new_node, "List should point to the new node");

    if (lst) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.content)).* == value, "Expected content to be 42");
        try assert.expect(node.next == null, "Expected next to be null");
    }
}

// Test adding a node to the front of a non-empty list
var test_lstadd_front_to_non_empty = TestCase{
    .name = "Add node to front of non-empty list",
    .fn_ptr = &test_lstadd_front_to_non_empty_fn,
};

fn test_lstadd_front_to_non_empty_fn(_: std.mem.Allocator) AssertError!void {
    const value1: u8 = 42;
    const value2: u8 = 84;

    var first_node: c.t_list = .{
        .content = @constCast(&value1),
        .next = null,
    };

    var lst: ?*c.t_list = &first_node;

    var new_node: c.t_list = .{
        .content = @constCast(&value2),
        .next = null,
    };

    ft_lstadd_front(&lst, &new_node);

    try assert.expect(lst != null, "List should not be null after adding node");
    try assert.expect(lst == &new_node, "List should point to the new node");

    if (lst) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.content)).* == value2, "Expected content to be 84");
        try assert.expect(node.next == &first_node, "Expected next to point to the first node");

        if (node.next) |next_node| {
            try assert.expect(@as(*u8, @ptrCast(next_node.*.content)).* == value1, "Expected content of next node to be 42");
            try assert.expect(next_node.*.next == null, "Expected next of next node to be null");
        }
    }
}

// Test adding many nodes to the front of the list
var test_lstadd_front_multiple = TestCase{
    .name = "Add multiple nodes to front of list",
    .fn_ptr = &test_lstadd_front_multiple_fn,
};

fn test_lstadd_front_multiple_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const values: [5]u8 = .{ 1, 2, 3, 4, 5 };
    var lst: ?*c.t_list = null;

    for (&values) |*value| {
        var new_node = try allocator.create(c.t_list);
        new_node.content = @constCast(value);

        ft_lstadd_front(&lst, new_node);
    }

    // Now the list should have 5 nodes with values 5, 4, 3, 2, 1
    var current = lst;
    for (0..5) |expected_value| {
        try assert.expect(current != null, "List should have enough nodes");
        if (current) |node| {
            try assert.expect(@as(*u8, @ptrCast(node.content)).* == (5 - expected_value), "Node content mismatch");
            current = node.next;
        }
    }
    try assert.expect(current == null, "List should end after 5 nodes");
}

var test_cases = [_]*TestCase{
    &test_lstadd_front_to_empty,
    &test_lstadd_front_to_non_empty,
    &test_lstadd_front_multiple,
};

pub var suite = TestSuite{
    .name = "ft_lstadd_front",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
