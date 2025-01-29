const std = @import("std");
const engine = @import("lib.zig");

pub const Rem = f64;
pub const RemStr = []const u8;
pub const Px = i64;

pub var base_font_size: Px = 16;
pub var user_font_scaling_factor: i64 = 1;
pub var dpi_font_scaling_factor: i64 = 1;
pub var root_font_size: Px = 0;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

/// Called every frame, scales our root font size
pub fn scaleRootFontSize() !void {
    var ddpi: f32 = 0;
    var hdpi: f32 = 0;
    var vdpi: f32 = 0;
    const display_index = engine.sdl.SDL_GetWindowDisplayIndex(engine.lifecycle.sdl_window);
    _ = engine.sdl.SDL_GetDisplayDPI(display_index, &ddpi, &hdpi, &vdpi);
    if (vdpi >= 200) {
        dpi_font_scaling_factor = 3;
    }
    root_font_size = base_font_size * (dpi_font_scaling_factor + user_font_scaling_factor);
}

/// Get how many pixels the given rem value should be;
pub fn getPixelsForRem(rem: Rem) Px {
    const px_float: f64 = @floatFromInt(root_font_size);
    const x: Px = @intFromFloat(@round(rem * px_float));
    std.debug.print("Rem {d}-> Pixels :{d}\n", .{ rem, x });
    return x;
}

/// Helper to convert a Rem to a RemStr, which is a string representation of the underlying f64
pub fn convertRemToRemStr(rem: Rem) !RemStr {
    const rem_str = try std.fmt.allocPrint(allocator, "{d}", .{rem});
    return rem_str;
}

/// Represents the supported alignment modes.
pub const AlignmentMode = enum { BEGIN, MIDDLE, END };

/// Represents the bounds that a widget can draw within, along with some drawing metadata.
/// It's up to each widget to draw themselves. The engine will pass along an instance of this to the
/// component lifecycle `render()` function for each widget, and said component can modify the padding,
/// vertical or horizontal alignment fields. For advanced usage, they can also modify the min/max fields
/// to achieve an "absolute" positioning effect.
pub const BoundsContext = struct {
    min_w: u64,
    max_w: u64,
    min_h: u64,
    max_h: u64,
    padding: u64 = 0,
    vertical_alignment: AlignmentMode = AlignmentMode.BEGIN,
    horizontal_alignment: AlignmentMode = AlignmentMode.BEGIN,
};
