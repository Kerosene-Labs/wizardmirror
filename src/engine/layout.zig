const std = @import("std");
const engine = @import("lib.zig");

const log = std.log.scoped(.engine_layout);

pub const Rem = f32;
pub const RemStr = []const u8;
pub const FloatPx = f32;
pub const IntegerPx = i32;

pub var base_font_size: FloatPx = 16;
pub var dpi_font_scale_factor: FloatPx = 0;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

/// Get how many pixels the given rem value should be;
pub fn getPixelsForRem(rem: Rem) IntegerPx {
    const x: IntegerPx = @intFromFloat(@round(rem * base_font_size));
    return x;
}

/// Get how many pixels the given Rem value should be, as a float.
pub fn getFloatPixelsFromRem(rem: Rem) FloatPx {
    return rem * base_font_size;
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
