const std = @import("std");

pub fn info(message: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("[info] {s}\n", .{message});
}

pub fn unrecoverable(message: []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("[info] {s}\n", .{message});
    std.os.exit(1);
}
