const TestSuite = @import("tests").tests.TestSuite;
const TestCollection = @import("tests").tests.TestCollection;

const ft_isalpha = @import("ft_isalpha.zig").suite;
const ft_isdigit = @import("ft_isdigit.zig").suite;
const ft_ialsnum = @import("ft_isalnum.zig").suite;
const ft_isascii = @import("ft_isascii.zig").suite;
const ft_isprint = @import("ft_isprint.zig").suite;
const ft_toupper = @import("ft_toupper.zig").suite;
const ft_tolower = @import("ft_tolower.zig").suite;
const ft_strlen = @import("ft_strlen.zig").suite;
const ft_strchr = @import("ft_strchr.zig").suite;
const ft_strrchr = @import("ft_strrchr.zig").suite;
const ft_strncmp = @import("ft_strncmp.zig").suite;
const ft_strlcpy = @import("ft_strlcpy.zig").suite;
const ft_strlcat = @import("ft_strlcat.zig").suite;

pub const base_test_collection = TestCollection{
    .name = "ZFT Base Tests",
    .suites = &[_]*TestSuite{
        @constCast(&ft_isalpha),
        @constCast(&ft_isdigit),
        @constCast(&ft_ialsnum),
        @constCast(&ft_isascii),
        @constCast(&ft_isprint),
        @constCast(&ft_toupper),
        @constCast(&ft_tolower),
        @constCast(&ft_strlen),
        @constCast(&ft_strchr),
        @constCast(&ft_strrchr),
        @constCast(&ft_strncmp),
        @constCast(&ft_strlcpy),
        @constCast(&ft_strlcat),
    },
};
