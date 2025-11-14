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
    not_run, // Test has not been executed yet
};

pub const InterceptSignal = enum {
    none,
    segv,
    abrt,
};

/// Global variable to track the last intercepted signal
var intercepted_signal: InterceptSignal = .none;

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
    /// Type of signal intercepted during test execution
    intercepted_signal: InterceptSignal = .none,
    /// Wether this test's expected outcome is speculative (i.e., undefined behavior)
    speculative: bool = false,
    /// Function pointer to the actual test implementation
    fn_ptr: *const fn (std.mem.Allocator) TestCaseError!void,

    /// Signal handler for catching segmentation faults during test execution
    /// Performs a longjmp to return control to the test runner
    fn segfaultHandler(sig: c_int) callconv(.c) void {
        _ = sig;
        intercepted_signal = .segv;
        c.longjmp(&jmp_buffer, 1);
    }

    fn abortHandler(sig: c_int) callconv(.c) void {
        _ = sig;
        intercepted_signal = .abrt;
        c.longjmp(&jmp_buffer, 1);
    }

    /// Prepares the test case for execution
    pub fn prepare(self: *TestCase) void {
        assert.clearFailure();
        self.result = .not_run;
        self.fail_info = null;
        self.intercepted_signal = .none;
    }

    /// Executes the test case and returns the result
    /// Handles segfaults by installing a temporary signal handler
    /// Returns TestResult indicating success, failure, or segfault
    pub fn run(self: *TestCase, allocator: std.mem.Allocator) TestResult {
        self.prepare();

        // Install signal handler for segfaults
        const old_segv_handler = c.signal(c.SIGSEGV, segfaultHandler);
        defer _ = c.signal(c.SIGSEGV, old_segv_handler);

        const old_abrt_handler = c.signal(c.SIGABRT, abortHandler);
        defer _ = c.signal(c.SIGABRT, old_abrt_handler);

        const jmp_result = c.setjmp(&jmp_buffer);

        // Catch when a return from segfault occured
        if (jmp_result != 0) {
            self.intercepted_signal = intercepted_signal;
            self.result = if (self.expect_segfault and intercepted_signal == .segv) TestResult.pass else TestResult.fail;
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
                TestResult.fail => {
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
