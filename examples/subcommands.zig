const std = @import("std");
const argsparse = @import("argonaut");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parser = try argsparse.newParser(allocator, "git", "A git-like command example");
    defer parser.deinit();

    const commit_cmd = try parser.newCommand("commit", "Record changes to the repository");
    var commit_msg_opts = argsparse.Options{
        .required = true,
        .help = "Commit message",
    };
    const commit_message = try commit_cmd.string("m", "message", &commit_msg_opts);
    const commit_all = try commit_cmd.flag("a", "all", null);

    const branch_cmd = try parser.newCommand("branch", "List, create, or delete branches");
    var branch_name_opts = argsparse.Options{
        .help = "Branch name",
    };
    const branch_name = try branch_cmd.string("", "name", &branch_name_opts);
    const branch_delete = try branch_cmd.flag("d", "delete", null);

    const push_cmd = try parser.newCommand("push", "Update remote refs");
    var remote_opts = argsparse.Options{
        .help = "Remote name",
        .default_string = "origin",
    };
    const remote = try push_cmd.string("", "remote", &remote_opts);
    const force = try push_cmd.flag("f", "force", null);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    parser.parse(args) catch |err| {
        std.debug.print("Error: {}\n\n", .{err});
        const usage_text = try parser.usage(null);
        defer allocator.free(usage_text);
        std.debug.print("{s}", .{usage_text});
        std.process.exit(1);
    };

    if (commit_cmd.happened) {
        std.debug.print("Committing changes...\n", .{});
        std.debug.print("Message: {s}\n", .{commit_message.*});
        if (commit_all.*) {
            std.debug.print("Including all changes\n", .{});
        }
    } else if (branch_cmd.happened) {
        if (branch_delete.*) {
            if (branch_name.*.len > 0) {
                std.debug.print("Deleting branch: {s}\n", .{branch_name.*});
            } else {
                std.debug.print("Error: branch name required for delete\n", .{});
            }
        } else if (branch_name.*.len > 0) {
            std.debug.print("Creating branch: {s}\n", .{branch_name.*});
        } else {
            std.debug.print("Listing branches...\n", .{});
        }
    } else if (push_cmd.happened) {
        std.debug.print("Pushing to remote: {s}\n", .{remote.*});
        if (force.*) {
            std.debug.print("Force push enabled\n", .{});
        }
    }
}