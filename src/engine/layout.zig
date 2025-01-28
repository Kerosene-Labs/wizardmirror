const std = @import("std");

pub const Rem = f64;
pub const RemStr = []const u8;
pub const Px = i64;

pub const root_font_size: Px = 16;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

/// Get how many pixels the given rem value should be;
pub fn getPixelsForRem(rem: Rem) Px {
    const x: Px = @intFromFloat(@round(rem * root_font_size));
    return x;
}

pub fn convertRemToRemStr(rem: Rem) !*RemStr {
    const rem_str = try std.fmt.allocPrint(allocator, "{d}", .{rem});
    return &rem_str;
}
