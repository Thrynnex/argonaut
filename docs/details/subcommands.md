# Subcommands

Argonaut handles nested commands gracefully.

```zig
var cmd = try parser.command("server", "Start the server");
const port = try cmd.int("p", "port", "Port to listen on");

try parser.parse(args);

if (cmd.happened()) {
    // Start server logic...
}
