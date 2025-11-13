const std = @import("std");
const assert = @import("assert.zig");
const AssertFailureInfo = assert.AssertFailureInfo;
const AssertError = assert.AssertError;

pub const TestCaseError = AssertError || std.mem.Allocator.Error;

const c = @cImport({
    @cInclude("setjmp.h");
    @cInclude("stddef.h");
    @cInclude("signal.h");
});

/// Represents the result of a single test case execution
pub const TestResult = enum {
    pass, // Test executed successfully without errors
    fail, // Test failed an assertion
    segfault, // Test caused a segmentation fault
    not_run, // Test has not been executed yet
};

/// Jump buffer for handling segfaults during test execution
var jmp_buffer: c.jmp_buf = undefined;

/// Represents a single test case with its execution logic
pub const TestCase = struct {
    /// Human-readable name for the test case
    name: []const u8,
    /// Optional longer description or notes for the test case
    description: ?[]const u8 = null,
    /// Current result of the test execution
    result: TestResult = .not_run,
    /// Information about test failure (if any)
    fail_info: ?AssertFailureInfo = null,
    /// Whether this test is expected to segfault (used for testing error conditions)
    expect_segfault: bool = false,
    /// Function pointer to the actual test implementation
    fn_ptr: *const fn (std.mem.Allocator) TestCaseError!void,

    /// Signal handler for catching segmentation faults during test execution
    /// Performs a longjmp to return control to the test runner
    fn segfaultHandler(sig: c_int) callconv(.c) void {
        _ = sig;
        c.longjmp(&jmp_buffer, 1);
    }

    /// Executes the test case and returns the result
    /// Handles segfaults by installing a temporary signal handler
    /// Returns TestResult indicating success, failure, or segfault
    pub fn run(self: *TestCase, allocator: std.mem.Allocator) TestResult {
        assert.clearFailure();

        // Install signal handler for segfaults
        const old_handler = c.signal(c.SIGSEGV, segfaultHandler);
        // Restore the old handler when the test is finished
        defer _ = c.signal(c.SIGSEGV, old_handler);

        const jmp_result = c.setjmp(&jmp_buffer);

        // Catch when a return from segfault occured
        if (jmp_result != 0) {
            self.result = if (self.expect_segfault) TestResult.pass else TestResult.segfault;
            return self.result;
        }

        self.fn_ptr(allocator) catch {
            self.result = .fail;
            self.fail_info = assert.getLastFailure();
            return self.result;
        };
        self.result = .pass;
        return self.result;
    }
};

/// Overall result status for a test suite
pub const TestSuiteResult = enum {
    failed, // At least one test in the suite failed
    success, // All tests in the suite passed
    skipped, // Test suite was skipped
};

/// Represents a collection of related test cases
pub const TestSuite = struct {
    /// Human-readable name for the test suite
    name: []const u8,
    /// Overall result of the test suite execution
    result: TestSuiteResult = .success,
    /// Array of test cases belonging to this suite
    cases: []*TestCase,

    /// Executes all test cases in the suite
    /// Sets the suite result based on individual test outcomes
    /// Uses an arena allocator for temporary allocations during execution
    pub fn run(self: *TestSuite, allocator: std.mem.Allocator) void {
        if (self.result == .skipped) return;
        for (self.cases) |case| {
            const result = case.run(allocator);

            switch (result) {
                TestResult.fail, TestResult.segfault => {
                    self.result = .failed;
                },
                else => {},
            }
        }
    }
};

/// Represents a collection of test suites
pub const TestCollection = struct {
    /// Human-readable name for the test collection
    name: []const u8,
    /// Array of test suites in the collection
    suites: []const *TestSuite,
    /// Executes all test suites in the collection
    /// Uses an arena allocator for temporary allocations during execution
    pub fn run(self: *TestCollection, allocator: std.mem.Allocator) void {
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        for (self.suites) |suite| {
            suite.run(arena.allocator());
        }
    }
};
