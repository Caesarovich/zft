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

// Helper mapping function that doubles integers
fn double_map_function(content: ?*anyopaque) callconv(.c) ?*anyopaque {
    if (content == null) return null;

    const input_value = @as(*u8, @ptrCast(@alignCast(content)));

    std.debug.print("content: {any}\n", .{content});

    std.debug.print("Doubling value: {}\n", .{input_value.*});

    const new_value = c.malloc(@sizeOf(u8));
    if (new_value == null) return null;

    const output_value = @as(*u8, @ptrCast(@alignCast(new_value)));
    output_value.* = input_value.* * 2;

    std.debug.print("Doubled value: {}\n", .{output_value.*});
    return new_value;
}

// Helper mapping function that creates a copy of a string with "copy_" prefix
fn copy_string_map_function(content: ?*anyopaque) callconv(.c) ?*anyopaque {
    if (content == null) return null;

    const input_str = @as([*:0]const u8, @ptrCast(content));
    const prefix = "copy_";
    const input_len = c.strlen(input_str);
    const prefix_len = c.strlen(prefix);

    const new_str = c.malloc(prefix_len + input_len + 1);
    if (new_str == null) return null;

    const output_str = @as([*]u8, @ptrCast(new_str));
    _ = c.strcpy(output_str, prefix);
    _ = c.strcat(output_str, input_str);

    return new_str;
}

// Helper mapping function that creates incrementing numbers
var increment_counter: u8 = 0;
fn increment_map_function(content: ?*anyopaque) callconv(.c) ?*anyopaque {
    _ = content; // We ignore the input content for this test

    const new_value = c.malloc(@sizeOf(u8));
    if (new_value == null) return null;

    const output_value = @as(*u8, @ptrCast(@alignCast(new_value)));
    output_value.* = increment_counter;
    increment_counter += 1;

    return new_value;
}

// Helper deletion function for cleanup
fn simple_map_delete_function(content: ?*anyopaque) callconv(.c) void {
    if (content) |ptr| {
        c.free(ptr);
    }
}

// Test mapping an empty list
var test_lstmap_empty = TestCase{
    .name = "Map empty list",
    .fn_ptr = &test_lstmap_empty_fn,
};

fn test_lstmap_empty_fn(_: std.mem.Allocator) AssertError!void {
    const new_list = c.ft_lstmap(null, &double_map_function, &simple_map_delete_function);
    try assert.expect(new_list == null, "Expected mapping empty list to return null");
}

// Test mapping a single node list
var test_lstmap_single = TestCase{
    .name = "Map single node list",
    .fn_ptr = &test_lstmap_single_fn,
};

fn test_lstmap_single_fn(_: std.mem.Allocator) AssertError!void {
    var value: u8 = 21;
    var node: c.t_list = .{
        .content = &value,
        .next = null,
    };

    const new_list: [*c]c.t_list = c.ft_lstmap(&node, &double_map_function, &simple_map_delete_function);
    try assert.expect(new_list != null, "Expected new list to be created");

    if (new_list) |list| {
        try assert.expect(list.*.content != null, "Expected new node to have content");
        if (list.*.content) |content| {
            const new_value = @as(*u8, @ptrCast(@alignCast(content)));
            try assert.expect(new_value.* == 42, "Expected doubled value to be 42");
        }
        try assert.expect(list.*.next == null, "Expected single node list");

        // Clean up
        var list_start: ?*c.t_list = list;
        c.ft_lstclear(&list_start, &simple_map_delete_function);
    }
}

// Test mapping multiple nodes
var test_lstmap_multiple = TestCase{
    .name = "Map multiple node list",
    .fn_ptr = &test_lstmap_multiple_fn,
};

fn test_lstmap_multiple_fn(_: std.mem.Allocator) AssertError!void {
    var value1: u8 = 1;
    var value2: u8 = 2;
    var value3: u8 = 3;

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

    const new_list = c.ft_lstmap(&node1, &double_map_function, &simple_map_delete_function);
    try assert.expect(new_list != null, "Expected new list to be created");

    if (new_list) |list| {
        var current: ?*c.t_list = list;
        const expected_values = [_]u8{ 2, 4, 6 };

        for (expected_values) |expected| {
            try assert.expect(current != null, "Expected node to exist");
            if (current) |node| {
                try assert.expect(node.content != null, "Expected node to have content");
                if (node.content) |content| {
                    const actual_value = @as(*u8, @ptrCast(@alignCast(content)));
                    try assert.expect(actual_value.* == expected, "Expected doubled value");
                }
                current = node.next;
            }
        }
        try assert.expect(current == null, "Expected end of list");

        // Clean up
        var list_start: ?*c.t_list = list;
        c.ft_lstclear(&list_start, &simple_map_delete_function);
    }
}

// Test mapping strings
var test_lstmap_strings = TestCase{
    .name = "Map string list",
    .fn_ptr = &test_lstmap_strings_fn,
};

fn test_lstmap_strings_fn(_: std.mem.Allocator) AssertError!void {
    const str1 = "hello";
    const str2 = "world";

    var node2: c.t_list = .{
        .content = @constCast(str2),
        .next = null,
    };

    var node1: c.t_list = .{
        .content = @constCast(str1),
        .next = &node2,
    };

    const new_list = c.ft_lstmap(&node1, &copy_string_map_function, &simple_map_delete_function);
    try assert.expect(new_list != null, "Expected new list to be created");

    if (new_list) |list| {
        // Check first node
        try assert.expect(list.*.content != null, "Expected first node to have content");
        if (list.*.content) |content| {
            const str = @as([*:0]const u8, @ptrCast(content));
            try assert.expect(c.strcmp(str, "copy_hello") == 0, "Expected 'copy_hello'");
        }

        // Check second node
        try assert.expect(list.*.next != null, "Expected second node to exist");
        if (list.*.next) |second_node| {
            try assert.expect(second_node.*.content != null, "Expected second node to have content");
            if (second_node.*.content) |content| {
                const str = @as([*:0]const u8, @ptrCast(content));
                try assert.expect(c.strcmp(str, "copy_world") == 0, "Expected 'copy_world'");
            }
            try assert.expect(second_node.*.next == null, "Expected end of list");
        }

        // Clean up
        var list_start: ?*c.t_list = list;
        c.ft_lstclear(&list_start, &simple_map_delete_function);
    }
}

// Test mapping with counter function
var test_lstmap_counter = TestCase{
    .name = "Map with counter function",
    .fn_ptr = &test_lstmap_counter_fn,
};

fn test_lstmap_counter_fn(_: std.mem.Allocator) AssertError!void {
    increment_counter = 0; // Reset counter

    var dummy1: u8 = 10;
    var dummy2: u8 = 20;
    var dummy3: u8 = 30;

    var node3: c.t_list = .{
        .content = &dummy3,
        .next = null,
    };

    var node2: c.t_list = .{
        .content = &dummy2,
        .next = &node3,
    };

    var node1: c.t_list = .{
        .content = &dummy1,
        .next = &node2,
    };

    const new_list = c.ft_lstmap(&node1, &increment_map_function, &simple_map_delete_function);
    try assert.expect(new_list != null, "Expected new list to be created");

    if (new_list) |list| {
        var current: ?*c.t_list = list;
        for (0..3) |expected| {
            try assert.expect(current != null, "Expected node to exist");
            if (current) |node| {
                try assert.expect(node.content != null, "Expected node to have content");
                if (node.content) |content| {
                    const actual_value = @as(*u8, @ptrCast(@alignCast(content)));
                    try assert.expect(actual_value.* == expected, "Expected incremented value");
                }
                current = node.next;
            }
        }
        try assert.expect(current == null, "Expected end of list");

        // Clean up
        var list_start: ?*c.t_list = list;
        c.ft_lstclear(&list_start, &simple_map_delete_function);
    }
}

var test_cases = [_]*TestCase{
    &test_lstmap_empty,
    &test_lstmap_single,
    &test_lstmap_multiple,
    &test_lstmap_strings,
    &test_lstmap_counter,
};

const is_function_defined = function_list.hasFunction("ft_lstmap");

pub var suite = TestSuite{
    .name = "ft_lstmap",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
