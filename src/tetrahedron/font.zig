const std = @import("std");
const tetrahedron = @import("root.zig");

const log = std.log.scoped(.tetrahedron_font);
const allocator = std.heap.page_allocator;

pub const FontWeight = []const u8;
pub const FontWeights = struct {
    pub const REGULAR = "Regular";
    pub const SEMIBOLD = "SemiBold";
    pub const BOLD = "Bold";
};

/// Represents our key in the font cache. When the programmer requests Xrem, we also store the pixels use to draw that.
/// This is useful for when our scaling factors change, as they don't directly affect rem.
pub const FontRemPxMap = struct {
    rem: tetrahedron.layout.Rem,
    px: tetrahedron.layout.FloatPx,
    weight: FontWeight,
};

/// HashMap Context
const FontRemPxMapKeyContext = struct {
    pub fn hash(_: @This(), key: FontRemPxMap) u64 {
        const rem_bits: u32 = @bitCast(key.rem);
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(std.mem.asBytes(&rem_bits));
        hasher.update(std.fmt.allocPrint(allocator, "{d}", .{key.px}) catch |err| {
            std.debug.panic("{any}", .{err});
        });
        return hasher.final();
    }

    pub fn eql(_: @This(), a: FontRemPxMap, b: FontRemPxMap) bool {
        return a.rem == b.rem and a.px == b.px;
    }
};

var font_cache = std.HashMap(FontRemPxMap, *tetrahedron.sdl.TTF_Font, FontRemPxMapKeyContext, std.hash_map.default_max_load_percentage).init(allocator);

/// Get a font with the requested REM size. Returns a pointer to a TTF_font.
pub fn getFont(requested_rem: tetrahedron.layout.Rem, weight: FontWeight) !*tetrahedron.sdl.TTF_Font {
    // create our key, get our potential cache hit
    const key = FontRemPxMap{
        .rem = requested_rem,
        .px = tetrahedron.layout.getFloatPixelsFromRem(requested_rem),
        .weight = weight,
    };
    var cached = font_cache.get(key);

    // if we're not cached, open the font and cache it
    if (cached == null) {
        const font_name = try std.fmt.allocPrintZ(allocator, "/usr/share/fonts/open-sans/OpenSans-{s}.ttf", .{weight});
        cached = tetrahedron.sdl.TTF_OpenFont(font_name, 16);
        if (cached == null) {
            std.debug.panic("{s}", .{try std.fmt.allocPrint(allocator, "failed to open font: {s}", .{tetrahedron.sdl.SDL_GetError()})});
        }
        font_cache.put(key, cached.?) catch {
            @panic("Failed to convert rem to remstr, probably out of memory");
        };
    }
    return cached.?;
}
