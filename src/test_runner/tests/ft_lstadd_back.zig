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

const is_function_defined = function_list.hasFunction("ft_lstadd_back");

fn ft_lstadd_back(lst: ?*?*c.t_list, new: ?*c.t_list) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_lstadd_back(lst, new);
    }
}

// Test adding a node to the back of an empty list
var test_lstadd_back_to_empty = TestCase{
    .name = "Add node to back of empty list",
    .fn_ptr = &test_lstadd_back_to_empty_fn,
};

fn test_lstadd_back_to_empty_fn(_: std.mem.Allocator) AssertError!void {
    const value: u8 = 42;
    var lst: ?*c.t_list = null;
    var new_node: c.t_list = .{
        .content = @constCast(&value),
        .next = null,
    };

    ft_lstadd_back(&lst, &new_node);

    try assert.expect(lst != null, "List should not be null after adding node");
    try assert.expect(lst == &new_node, "List should point to the new node");

    if (lst) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.content)).* == value, "Expected content to be 42");
        try assert.expect(node.next == null, "Expected next to be null");
    }
}

// Test adding a node to the back of a non-empty list
var test_lstadd_back_to_non_empty = TestCase{
    .name = "Add node to back of non-empty list",
    .fn_ptr = &test_lstadd_back_to_non_empty_fn,
};

fn test_lstadd_back_to_non_empty_fn(_: std.mem.Allocator) AssertError!void {
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

    ft_lstadd_back(&lst, &new_node);

    try assert.expect(lst != null, "List should not be null after adding node");
    try assert.expect(lst == &first_node, "List should still point to the first node");

    if (lst) |node| {
        try assert.expect(@as(*u8, @ptrCast(node.content)).* == value1, "Expected content to be 42");
        try assert.expect(node.next == &new_node, "Expected next to point to the new node");

        if (node.next) |next_node| {
            try assert.expect(@as(*u8, @ptrCast(next_node.*.content)).* == value2, "Expected content of next node to be 84");
            try assert.expect(next_node.*.next == null, "Expected next of next node to be null");
        }
    }
}

// Test adding multiple nodes to the back of the list
var test_lstadd_back_multiple = TestCase{
    .name = "Add multiple nodes to back of list",
    .fn_ptr = &test_lstadd_back_multiple_fn,
};

fn test_lstadd_back_multiple_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const values: [5]u8 = .{ 1, 2, 3, 4, 5 };
    var lst: ?*c.t_list = null;

    for (&values) |*value| {
        var new_node = try allocator.create(c.t_list);
        new_node.content = @constCast(value);
        new_node.next = null;

        ft_lstadd_back(&lst, new_node);
    }

    // Now the list should have 5 nodes with values 1, 2, 3, 4, 5
    var current = lst;
    for (0..5) |expected_value| {
        try assert.expect(current != null, "List should have enough nodes");
        if (current) |node| {
            try assert.expect(@as(*u8, @ptrCast(node.content)).* == (expected_value + 1), "Node content mismatch");
            current = node.next;
        }
    }
    try assert.expect(current == null, "List should end after 5 nodes");
}

// Test adding a list to the back of the list
var test_lstadd_back_list = TestCase{
    .name = "Add list to back of list",
    .fn_ptr = &test_lstadd_back_list_fn,
};

fn test_lstadd_back_list_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const values1: [5]u8 = .{ 1, 2, 3, 4, 5 };
    var lst1: ?*c.t_list = null;

    for (&values1) |*value| {
        var new_node = try allocator.create(c.t_list);
        new_node.content = @constCast(value);
        new_node.next = null;

        ft_lstadd_back(&lst1, new_node);
    }

    const values2: [5]u8 = .{ 0, 2, 4, 6, 8 };
    var lst2: ?*c.t_list = null;

    for (&values2) |*value| {
        var new_node = try allocator.create(c.t_list);
        new_node.content = @constCast(value);
        new_node.next = null;

        ft_lstadd_back(&lst2, new_node);
    }

    ft_lstadd_back(&lst1, lst2);

    // Now the list should have 5 nodes with values 1, 2, 3, 4, 5
    var current = lst1;
    for (0..5) |expected_value| {
        try assert.expect(current != null, "List should have enough nodes");
        if (current) |node| {
            try assert.expect(@as(*u8, @ptrCast(node.content)).* == (expected_value + 1), "Node content mismatch");
            current = node.next;
        }
    }

    //And after it should have 5 nodes with values 0, 2, 4, 6, 8
    for (0..5) |expected_value| {
        try assert.expect(current != null, "List should have enough nodes");
        if (current) |node| {
            try assert.expect(@as(*u8, @ptrCast(node.content)).* == (expected_value * 2), "Node content mismatch");
            current = node.next;
        }
    }

    try assert.expect(current == null, "List should end after 10 nodes");
}

var test_cases = [_]*TestCase{
    &test_lstadd_back_to_empty,
    &test_lstadd_back_to_non_empty,
    &test_lstadd_back_multiple,
    &test_lstadd_back_list,
};

pub var suite = TestSuite{
    .name = "ft_lstadd_back",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
