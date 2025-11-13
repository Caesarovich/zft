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

const is_function_defined = function_list.hasFunction("ft_lstdelone");

fn ft_lstdelone(lst: ?*c.t_list, del: ?*const fn (?*anyopaque) callconv(.c) void) void {
    if (comptime !is_function_defined) {
        return;
    } else {
        c.ft_lstdelone(lst, del);
    }
}

// Helper deletion function that tracks calls
var delete_call_count: u32 = 0;

fn test_delete_function(content: ?*anyopaque) callconv(.c) void {
    delete_call_count += 1;
    if (content) |ptr| {
        c.free(ptr);
    }
}

// Test deleting a node with allocated content
var test_lstdelone_with_content = TestCase{
    .name = "Delete node with allocated content",
    .fn_ptr = &test_lstdelone_with_content_fn,
};

fn test_lstdelone_with_content_fn(_: std.mem.Allocator) TestCaseError!void {
    delete_call_count = 0;

    // Create content that needs to be freed
    const content = c.malloc(10);
    try assert.expect(content != null, "Failed to allocate memory for content");

    const node = c.malloc(@sizeOf(c.t_list));
    try assert.expect(node != null, "Failed to allocate memory for node");

    const list_node: *c.t_list = @ptrCast(@alignCast(node));
    list_node.* = .{
        .content = content,
        .next = null,
    };

    ft_lstdelone(list_node, &test_delete_function);

    try assert.expect(delete_call_count == 1, "Expected delete function to be called once");
}

// Test deleting a node with null content
var test_lstdelone_null_content = TestCase{
    .name = "Delete node with null content",
    .fn_ptr = &test_lstdelone_null_content_fn,
};

fn test_lstdelone_null_content_fn(_: std.mem.Allocator) TestCaseError!void {
    delete_call_count = 0;

    const node = c.malloc(@sizeOf(c.t_list));
    try assert.expect(node != null, "Failed to allocate memory for node");

    const list_node: *c.t_list = @ptrCast(@alignCast(node));
    list_node.* = .{
        .content = null,
        .next = null,
    };

    ft_lstdelone(list_node, &test_delete_function);

    try assert.expect(delete_call_count == 1, "Expected delete function to be called once even with null content");
}

// Test deleting a node that has a next pointer (next should not be affected)
var test_lstdelone_with_next = TestCase{
    .name = "Delete node with next pointer",
    .fn_ptr = &test_lstdelone_with_next_fn,
};

fn test_lstdelone_with_next_fn(_: std.mem.Allocator) TestCaseError!void {
    delete_call_count = 0;

    const content1 = c.malloc(10);
    const content2 = c.malloc(10);
    try assert.expect(content1 != null and content2 != null, "Failed to allocate memory");

    if (content2) |ptr| {
        @as(*u8, @ptrCast(ptr)).* = 'A';
    }

    const node2 = c.malloc(@sizeOf(c.t_list));
    try assert.expect(node2 != null, "Failed to allocate memory for second node");

    const node2_ptr: *c.t_list = @ptrCast(@alignCast(node2));
    node2_ptr.* = .{
        .content = content2,
        .next = null,
    };

    const node1 = c.malloc(@sizeOf(c.t_list));
    try assert.expect(node1 != null, "Failed to allocate memory for first node");

    const node1_ptr: *c.t_list = @ptrCast(@alignCast(node1));
    node1_ptr.* = .{
        .content = content1,
        .next = node2_ptr,
    };

    // Delete only the first node
    ft_lstdelone(node1_ptr, &test_delete_function);

    try assert.expect(delete_call_count == 1, "Expected delete function to be called once");

    // This will crash if node2 was affected
    if (content2) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)).* == 'A', "Expected second node's content to remain intact");
    }
    c.free(content2);
    c.free(node2);
}

// Test deleting a NULL node pointer
var test_lstdelone_null_node = TestCase{
    .name = "Delete null node pointer",
    .speculative = true,
    .fn_ptr = &test_lstdelone_null_node_fn,
};

fn test_lstdelone_null_node_fn(_: std.mem.Allocator) TestCaseError!void {
    delete_call_count = 0;

    // Call ft_lstdelone with a null pointer
    ft_lstdelone(null, &test_delete_function);

    try assert.expect(delete_call_count == 0, "Expected delete function not to be called for null node");
}

// Test deleting a node with a null deletion function
var test_lstdelone_null_function = TestCase{
    .name = "Delete node with null deletion function",
    .speculative = true,
    .fn_ptr = &test_lstdelone_null_function_fn,
};

fn test_lstdelone_null_function_fn(_: std.mem.Allocator) TestCaseError!void {
    const content = c.malloc(10);
    try assert.expect(content != null, "Failed to allocate memory for content");
    defer c.free(content);

    const node = c.malloc(@sizeOf(c.t_list));
    try assert.expect(node != null, "Failed to allocate memory for node");

    const list_node: *c.t_list = @ptrCast(@alignCast(node));
    list_node.* = .{
        .content = content,
        .next = null,
    };

    // Call ft_lstdelone with a null deletion function
    ft_lstdelone(list_node, null);
}

var test_cases = [_]*TestCase{
    &test_lstdelone_with_content,
    &test_lstdelone_null_content,
    &test_lstdelone_with_next,
    &test_lstdelone_null_node,
    &test_lstdelone_null_function,
};

pub var suite = TestSuite{
    .name = "ft_lstdelone",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
