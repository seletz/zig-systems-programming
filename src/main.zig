const std = @import("std");
const options = @import("options");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    const args = try std.process.argsAlloc(ally);
    defer std.process.argsFree(ally, args);

    const cwd = std.fs.cwd();

    var stdout_buffer: [options.writer_buffer_size]u8 = undefined;
    var stderr_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    var stderr_writer = std.fs.File.stderr().writer(&stderr_buffer);
    const stdout = &stdout_writer.interface;
    const stderr = &stderr_writer.interface;

    for (args[1..]) |filepath| {
        const file = cwd.openFile(filepath, .{}) catch {
            stderr.print("could not open: {s}\n", .{filepath}) catch {};
            stderr.flush() catch {};
            continue;
        };
        defer file.close();
        var file_buffer: [options.reader_buffer_size]u8 = undefined;
        var file_reader = file.reader(&file_buffer);
        const reader = &file_reader.interface;

        _ = try reader.streamRemaining(stdout);
    }

    try stdout.flush();
}
