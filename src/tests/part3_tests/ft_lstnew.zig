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

const is_function_defined = function_list.hasFunction("ft_lstnew");

fn ft_lstnew(content: ?*anyopaque) ?*c.t_list {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_lstnew(content);
    }
}

// Test ft_lstnew with valid content
var test_lstnew_valid_content = TestCase{
    .name = "Create new node with valid content",
    .fn_ptr = &test_lstnew_valid_content_fn,
};

fn test_lstnew_valid_content_fn(_: std.mem.Allocator) TestCaseError!void {
    const value: u8 = 42;
    const node = ft_lstnew(@constCast(&value));
    try assert.expect(node != null, "ft_lstnew should return a valid pointer");
    defer c.free(node);

    if (node) |nodePtr| {
        if (nodePtr.content) |contentPtr| {
            try assert.expect(@as(*u8, @ptrCast(contentPtr)).* == 42, "Expected content to be 42");
        } else {
            try assert.expect(false, "Expected content to be non-null");
        }

        try assert.expect(nodePtr.next == null, "Expected next to be null");
    }
}

// Test ft_lstnew with null content
var test_lstnew_null_content = TestCase{
    .name = "Create new node with null content",
    .fn_ptr = &test_lstnew_null_content_fn,
};

fn test_lstnew_null_content_fn(_: std.mem.Allocator) TestCaseError!void {
    const node = ft_lstnew(null);
    try assert.expect(node != null, "ft_lstnew should return a valid pointer");
    defer c.free(node);

    if (node) |nodePtr| {
        try assert.expect(nodePtr.content == null, "Expected content to be null");
        try assert.expect(nodePtr.next == null, "Expected next to be null");
    }
}

// Test ft_lstnew with string content
var test_lstnew_string_content = TestCase{
    .name = "Create new node with string content",
    .fn_ptr = &test_lstnew_string_content_fn,
};

fn test_lstnew_string_content_fn(_: std.mem.Allocator) TestCaseError!void {
    const content = "Hello";
    const node = ft_lstnew(@constCast(content));
    try assert.expect(node != null, "ft_lstnew should return a valid pointer");
    defer c.free(node);

    if (node) |nodePtr| {
        if (nodePtr.content) |contentPtr| {
            try assert.expect(@as([*]const u8, @ptrCast(contentPtr)) == content, "Expected content to be 'Hello'");
        } else {
            try assert.expect(false, "Expected content to be non-null");
        }

        try assert.expect(nodePtr.next == null, "Expected next to be null");
    }
}

// Test multiple ft_lstnew calls
var test_lstnew_multiple = TestCase{
    .name = "Create multiple new nodes",
    .fn_ptr = &test_lstnew_multiple_fn,
};

fn test_lstnew_multiple_fn(_: std.mem.Allocator) TestCaseError!void {
    const value1: u8 = 1;
    const value2: u8 = 2;
    const value3: u8 = 3;

    const node1 = ft_lstnew(@constCast(&value1));
    try assert.expect(node1 != null, "First node should be valid");
    defer c.free(node1);

    const node2 = ft_lstnew(@constCast(&value2));
    try assert.expect(node2 != null, "Second node should be valid");
    defer c.free(node2);

    const node3 = ft_lstnew(@constCast(&value3));
    try assert.expect(node3 != null, "Third node should be valid");
    defer c.free(node3);

    if (node1 == node2 or node2 == node3 or node1 == node3) {
        try assert.expect(false, "Nodes should be different");
    }

    if (node1) |n1| {
        if (n1.content) |contentPtr1| {
            try assert.expect(@as(*u8, @ptrCast(contentPtr1)).* == 1, "Expected first node content to be 1");
        } else {
            try assert.expect(false, "Expected first node content to be non-null");
        }
    }

    if (node2) |n2| {
        if (n2.content) |contentPtr2| {
            try assert.expect(@as(*u8, @ptrCast(contentPtr2)).* == 2, "Expected second node content to be 2");
        } else {
            try assert.expect(false, "Expected second node content to be non-null");
        }
    }

    if (node3) |n3| {
        if (n3.content) |contentPtr3| {
            try assert.expect(@as(*u8, @ptrCast(contentPtr3)).* == 3, "Expected third node content to be 3");
        } else {
            try assert.expect(false, "Expected third node content to be non-null");
        }
    }
}

var test_cases = [_]*TestCase{
    &test_lstnew_valid_content,
    &test_lstnew_null_content,
    &test_lstnew_string_content,
    &test_lstnew_multiple,
};

pub var suite = TestSuite{
    .name = "ft_lstnew",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
