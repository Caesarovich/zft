const TestSuite = @import("tests").tests.TestSuite;
const TestCollection = @import("tests").tests.TestCollection;

pub var bonus_test_collection = TestCollection{
    .name = "ZFT Bonus Tests",
    .suites = &[_]*TestSuite{
        &@import("ft_lstnew.zig").suite,
        &@import("ft_lstadd_front.zig").suite,
        &@import("ft_lstsize.zig").suite,
        &@import("ft_lstlast.zig").suite,
        &@import("ft_lstadd_back.zig").suite,
        &@import("ft_lstdelone.zig").suite,
        &@import("ft_lstclear.zig").suite,
        &@import("ft_lstiter.zig").suite,
        &@import("ft_lstmap.zig").suite,
    },
};
