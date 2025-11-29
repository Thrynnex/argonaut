const std = @import("std");
const argsparse = @import("argonaut");

fn validatePort(args: []const []const u8) !void {
    if (args.len != 1) return;
    const port = try std.fmt.parseInt(u16, args[0], 10);
    if (port < 1024) {
        return error.PortTooLow;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parser = try argsparse.newParser(allocator, "advanced-example", "Advanced features demonstration");
    defer parser.deinit();

    const verbose = try parser.flagCounter("v", "verbose", null);

    var port_opts = argsparse.Options{
        .help = "Server port (must be >= 1024)",
        .default_int = 8080,
        .validate = validatePort,
    };
    const port = try parser.int("p", "port", &port_opts);

    var files_opts = argsparse.Options{
        .help = "Input files to process",
    };
    const files = try parser.stringList("f", "file", &files_opts);

    const input_file = try parser.stringPositional(null);

    var numbers_opts = argsparse.Options{
        .help = "List of numbers",
    };
    const numbers = try parser.intList("n", "number", &numbers_opts);

    var thresholds_opts = argsparse.Options{
        .help = "Threshold values",
        .default_float_list = &[_]f64{ 0.5, 0.75, 0.9 },
    };
    const thresholds = try parser.floatList("t", "threshold", &thresholds_opts);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    parser.parse(args) catch |err| {
        std.debug.print("Error: {}\n\n", .{err});
        const usage_text = try parser.usage(null);
        defer allocator.free(usage_text);
        std.debug.print("{s}", .{usage_text});
        std.process.exit(1);
    };

    std.debug.print("Verbosity level: {d}\n", .{verbose.*});
    std.debug.print("Port: {d}\n", .{port.*});

    if (input_file.*.len > 0) {
        std.debug.print("Input file: {s}\n", .{input_file.*});
    }

    if (files.items.len > 0) {
        std.debug.print("Additional files:\n", .{});
        for (files.items) |file| {
            std.debug.print("  - {s}\n", .{file});
        }
    }

    if (numbers.items.len > 0) {
        std.debug.print("Numbers: ", .{});
        for (numbers.items, 0..) |num, i| {
            if (i > 0) std.debug.print(", ", .{});
            std.debug.print("{d}", .{num});
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("Thresholds: ", .{});
    for (thresholds.items, 0..) |threshold, i| {
        if (i > 0) std.debug.print(", ", .{});
        std.debug.print("{d:.2}", .{threshold});
    }
    std.debug.print("\n", .{});
}