const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    const args = try std.process.argsAlloc(ally);
    defer std.process.argsFree(ally, args);

    const cwd = std.fs.cwd();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    for (args[1..]) |filepath| {
        const max_bytes = 16 * 1024 * 1024;
        const text = try cwd.readFileAlloc(ally, filepath, max_bytes);
        defer ally.free(text);

        try stdout.writeAll(text);
    }

    try stdout.flush();
}
