const std = @import("std");
const engine = @import("lib.zig");

pub const Rem = f64;
pub const RemStr = []const u8;
pub const Px = i64;

pub var base_font_size: Px = 16;
pub var font_scaling_factor: i64 = 4;
pub var root_font_size: Px = 0;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn scaleRootFontSize() !void {
    var ddpi: f32 = 0;
    var hdpi: f32 = 0;
    var vdpi: f32 = 0;
    const display_index = engine.sdl.SDL_GetWindowDisplayIndex(engine.lifecycle.sdl_window);
    _ = engine.sdl.SDL_GetDisplayDPI(display_index, &ddpi, &hdpi, &vdpi);
    std.debug.print("{d}\n", .{vdpi});
    if (vdpi >= 200) {
        font_scaling_factor = 6;
    }
    root_font_size = base_font_size * font_scaling_factor;
}

/// Get how many pixels the given rem value should be;
pub fn getPixelsForRem(rem: Rem) Px {
    const px_float: f64 = @floatFromInt(root_font_size);
    const x: Px = @intFromFloat(@round(rem * px_float));
    return x;
}

pub fn convertRemToRemStr(rem: Rem) !RemStr {
    const rem_str = try std.fmt.allocPrint(allocator, "{d}", .{rem});
    return rem_str;
}
