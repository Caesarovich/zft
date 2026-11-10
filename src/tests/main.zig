const TestSuite = @import("test-framework").tests.TestSuite;
const TestCollection = @import("test-framework").tests.TestCollection;

pub var part1_test_collection = TestCollection{
    .name = "Part 1 - Libc functions",
    .suites = &[_]*TestSuite{
        &@import("part1_tests/ft_isalpha.zig").suite,
        &@import("part1_tests/ft_isdigit.zig").suite,
        &@import("part1_tests/ft_isalnum.zig").suite,
        &@import("part1_tests/ft_isascii.zig").suite,
        &@import("part1_tests/ft_isprint.zig").suite,
        &@import("part1_tests/ft_toupper.zig").suite,
        &@import("part1_tests/ft_tolower.zig").suite,
        &@import("part1_tests/ft_strlen.zig").suite,
        &@import("part1_tests/ft_strchr.zig").suite,
        &@import("part1_tests/ft_strrchr.zig").suite,
        &@import("part1_tests/ft_strncmp.zig").suite,
        &@import("part1_tests/ft_strlcpy.zig").suite,
        &@import("part1_tests/ft_strlcat.zig").suite,
        &@import("part1_tests/ft_strnstr.zig").suite,
        &@import("part1_tests/ft_memset.zig").suite,
        &@import("part1_tests/ft_bzero.zig").suite,
        &@import("part1_tests/ft_memcpy.zig").suite,
        &@import("part1_tests/ft_memmove.zig").suite,
        &@import("part1_tests/ft_memchr.zig").suite,
        &@import("part1_tests/ft_memcmp.zig").suite,
        &@import("part1_tests/ft_atoi.zig").suite,
        &@import("part1_tests/ft_calloc.zig").suite,
        &@import("part1_tests/ft_strdup.zig").suite,
    },
};

pub var part2_test_collection = TestCollection{
    .name = "Part 2 - Additional functions",
    .suites = &[_]*TestSuite{
        &@import("part2_tests/ft_substr.zig").suite,
        &@import("part2_tests/ft_strjoin.zig").suite,
        &@import("part2_tests/ft_strtrim.zig").suite,
        &@import("part2_tests/ft_split.zig").suite,
        &@import("part2_tests/ft_itoa.zig").suite,
        &@import("part2_tests/ft_strmapi.zig").suite,
        &@import("part2_tests/ft_striteri.zig").suite,
        &@import("part2_tests/ft_putchar_fd.zig").suite,
        &@import("part2_tests/ft_putstr_fd.zig").suite,
        &@import("part2_tests/ft_putendl_fd.zig").suite,
        &@import("part2_tests/ft_putnbr_fd.zig").suite,
    },
};

pub var part3_test_collection = TestCollection{
    .name = "Part 3 - Linked lists",
    .suites = &[_]*TestSuite{
        &@import("part3_tests/ft_lstnew.zig").suite,
        &@import("part3_tests/ft_lstadd_front.zig").suite,
        &@import("part3_tests/ft_lstsize.zig").suite,
        &@import("part3_tests/ft_lstlast.zig").suite,
        &@import("part3_tests/ft_lstadd_back.zig").suite,
        &@import("part3_tests/ft_lstdelone.zig").suite,
        &@import("part3_tests/ft_lstclear.zig").suite,
        &@import("part3_tests/ft_lstiter.zig").suite,
        &@import("part3_tests/ft_lstmap.zig").suite,
    },
};
