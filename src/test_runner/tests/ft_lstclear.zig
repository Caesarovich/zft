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

const is_function_defined = function_list.hasFunction("ft_lstclear");

pub fn ft_lstclear(lst: ?*?*c.t_list, del: ?*const fn (?*anyopaque) callconv(.c) void) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_lstclear(lst, del);
    }
}

// Helper deletion function that tracks calls
var clear_delete_call_count: u32 = 0;

fn test_clear_delete_function(content: ?*anyopaque) callconv(.c) void {
    clear_delete_call_count += 1;
    if (content) |ptr| {
        c.free(ptr);
    }
}

// Test clearing an empty list
var test_lstclear_empty = TestCase{
    .name = "Clear empty list",
    .fn_ptr = &test_lstclear_empty_fn,
};

fn test_lstclear_empty_fn(_: std.mem.Allocator) AssertError!void {
    clear_delete_call_count = 0;
    var lst: ?*c.t_list = null;

    ft_lstclear(&lst, &test_clear_delete_function);

    try assert.expect(lst == null, "Expected list to remain null");
    try assert.expect(clear_delete_call_count == 0, "Expected delete function not to be called for empty list");
}

// Test clearing a single node list
var test_lstclear_single = TestCase{
    .name = "Clear single node list",
    .fn_ptr = &test_lstclear_single_fn,
};

fn test_lstclear_single_fn(_: std.mem.Allocator) AssertError!void {
    clear_delete_call_count = 0;

    const content = c.malloc(10);
    try assert.expect(content != null, "Failed to allocate memory for content (This is an error in the test, not in the function being tested)");

    const node = c.malloc(@sizeOf(c.t_list));
    try assert.expect(node != null, "Failed to allocate memory for node (This is an error in the test, not in the function being tested)");

    const list_node: *c.t_list = @ptrCast(@alignCast(node));
    list_node.content = content;
    list_node.next = null;

    var lst: ?*c.t_list = list_node;

    ft_lstclear(&lst, &test_clear_delete_function);

    try assert.expect(lst == null, "Expected list to be null after clearing");
    try assert.expect(clear_delete_call_count == 1, "Expected delete function to be called once");
}

// Test clearing a multiple node list
var test_lstclear_multiple = TestCase{
    .name = "Clear multiple node list",
    .fn_ptr = &test_lstclear_multiple_fn,
};

fn test_lstclear_multiple_fn(_: std.mem.Allocator) AssertError!void {
    clear_delete_call_count = 0;

    const node_count = 5;
    var lst: ?*c.t_list = null;
    var current: ?*c.t_list = null;

    // Create a list with multiple nodes
    for (0..node_count) |_| {
        const content = c.malloc(10);
        try assert.expect(content != null, "Failed to allocate memory for content (This is an error in the test, not in the function being tested)");

        const node_mem = c.malloc(@sizeOf(c.t_list));
        try assert.expect(node_mem != null, "Failed to allocate memory for node (This is an error in the test, not in the function being tested)");

        const new_node: *c.t_list = @ptrCast(@alignCast(node_mem));
        new_node.content = content;
        new_node.next = null;

        if (lst == null) {
            lst = new_node;
            current = lst;
        } else {
            current.?.next = new_node;
            current = new_node;
        }
    }

    ft_lstclear(&lst, &test_clear_delete_function);

    try assert.expect(lst == null, "Expected list to be null after clearing");
    try assert.expect(clear_delete_call_count == node_count, "Expected delete function to be called for each node");
}

var test_cases = [_]*TestCase{
    &test_lstclear_empty,
    &test_lstclear_single,
    &test_lstclear_multiple,
};

pub var suite = TestSuite{
    .name = "ft_lstclear",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
