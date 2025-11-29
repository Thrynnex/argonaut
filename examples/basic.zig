const std = @import("std");
const argsparse = @import("argonaut");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parser = try argsparse.newParser(allocator, "basic-example", "A basic example program");
    defer parser.deinit();

    const verbose = try parser.flag("v", "verbose", null);

    var name_opts = argsparse.Options{
        .required = true,
        .help = "Your name",
    };
    const name = try parser.string("n", "name", &name_opts);

    var age_opts = argsparse.Options{
        .help = "Your age",
        .default_int = 18,
    };
    const age = try parser.int("a", "age", &age_opts);

    var colors = [_][]const u8{ "red", "green", "blue" };
    var color_opts = argsparse.Options{
        .help = "Favorite color",
    };
    const color = try parser.selector("c", "color", &colors, &color_opts);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    _ = parser.parse(args) catch {
        const usage_text = try parser.usage(null);
        defer allocator.free(usage_text);
        std.debug.print("{s}", .{usage_text});
        std.process.exit(1);
    };

    if (verbose.*) {
        std.debug.print("Verbose mode enabled\n", .{});
    }

    std.debug.print("Name: {s}\n", .{name.*});
    std.debug.print("Age: {d}\n", .{age.*});

    if (color.*.len > 0) {
        std.debug.print("Favorite color: {s}\n", .{color.*});
    }
}
