
# Quick Start

Create a `main.zig` file:

```zig
const std = @import("std");
const argsparse = @import("argonaut");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 1. Init Parser
    var parser = try argsparse.newParser(allocator, "demo", "A demo app");
    defer parser.deinit();

    // 2. Define Args
    const name = try parser.string("n", "name", "Your Name");
    const count = try parser.int("c", "count", "Repetitions");

    // 3. Parse
    const args = try std.process.argsAlloc(allocator);
    try parser.parse(args);

    // 4. Use logic
    std.debug.print("Hello {s}\n", .{name.*});
}
