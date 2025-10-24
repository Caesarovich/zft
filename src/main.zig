const std = @import("std");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.

    std.debug.print("All your {s} are belong to us {d}.\n", .{ "codebase", c.ft_strlen("eeee") });
}
