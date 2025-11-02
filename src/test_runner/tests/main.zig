const TestSuite = @import("tests").tests.TestSuite;
const TestCollection = @import("tests").tests.TestCollection;

const ft_isalpha = @import("ft_isalpha.zig").suite;
const ft_isdigit = @import("ft_isdigit.zig").suite;
const ft_ialsnum = @import("ft_isalnum.zig").suite;
const ft_isascii = @import("ft_isascii.zig").suite;
const ft_isprintable = @import("ft_isprint.zig").suite;
const ft_strlen = @import("ft_strlen.zig").suite;

pub const base_test_collection = TestCollection{
    .name = "ZFT Base Tests",
    .suites = &[_]*TestSuite{
        @constCast(&ft_isalpha),
        @constCast(&ft_isdigit),
        @constCast(&ft_ialsnum),
        @constCast(&ft_isascii),
        @constCast(&ft_isprintable),
        @constCast(&ft_strlen),
    },
};
