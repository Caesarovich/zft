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
    @cInclude("ctype.h");
});

const is_function_defined = function_list.hasFunction("ft_lstsize");

fn ft_lstsize(lst: ?*c.t_list) c_int {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_lstsize(lst);
    }
}

// Test ft_lstsize with empty list
var test_lstsize_empty = TestCase{
    .name = "Size of empty list",
    .fn_ptr = &test_lstsize_empty_fn,
};

fn test_lstsize_empty_fn(_: std.mem.Allocator) AssertError!void {
    const size = ft_lstsize(null);
    try assert.expect(size == 0, "Expected size of empty list to be 0");
}

// Test ft_lstsize with single node list
var test_lstsize_single = TestCase{
    .name = "Size of single node list",
    .fn_ptr = &test_lstsize_single_fn,
};

fn test_lstsize_single_fn(_: std.mem.Allocator) AssertError!void {
    const value: u8 = 42;
    const lst: c.struct_s_list = .{
        .content = @constCast(&value),
        .next = null,
    };

    const size = ft_lstsize(@constCast(&lst));

    try assert.expect(size == 1, "Expected size of single node list to be 1");
}

// Test ft_lstsize with multiple node list
var test_lstsize_multiple = TestCase{
    .name = "Size of multiple node list",
    .fn_ptr = &test_lstsize_multiple_fn,
};

fn test_lstsize_multiple_fn(_: std.mem.Allocator) AssertError!void {
    const node3: c.struct_s_list = .{
        .content = null,
        .next = null,
    };
    const node2: c.struct_s_list = .{
        .content = null,
        .next = @constCast(&node3),
    };
    const lst: c.struct_s_list = .{
        .content = null,
        .next = @constCast(&node2),
    };

    const size = ft_lstsize(@constCast(&lst));
    try assert.expect(size == 3, "Expected size of three node list to be 3");
}

// Test ft_lstsize with large list
var test_lstsize_large = TestCase{
    .name = "Size of large list",
    .fn_ptr = &test_lstsize_large_fn,
};

fn test_lstsize_large_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const list_size = 1000;
    var head: ?*c.t_list = null;
    var current: ?*c.t_list = null;

    // Create a large list
    for (0..list_size) |_| {
        const new_node = allocator.create(c.t_list) catch return error.OutOfMemory;
        new_node.* = .{
            .content = null,
            .next = null,
        };

        if (head == null) {
            head = new_node;
            current = head;
        } else {
            current.?.next = new_node;
            current = new_node;
        }
    }

    const size = ft_lstsize(@constCast(head));
    try assert.expect(size == list_size, "Expected size of large list to match the number of nodes");
}

var test_cases = [_]*TestCase{
    &test_lstsize_empty,
    &test_lstsize_single,
    &test_lstsize_multiple,
    &test_lstsize_large,
};

pub var suite = TestSuite{
    .name = "ft_lstsize",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
