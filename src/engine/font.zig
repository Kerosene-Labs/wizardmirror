const std = @import("std");
const engine = @import("lib.zig");

const allocator = std.heap.page_allocator;
var font_cache = std.StringHashMap(*engine.sdl.TTF_Font).init(std.heap.page_allocator);

/// Get a font with the requested REM size. Returns a pointer to a TTF_font.
pub fn getFont(requested_rem: engine.layout.Rem) *engine.sdl.TTF_Font {
    var cached = font_cache.get(engine.layout.convertRemToRemStr(requested_rem) catch {
        @panic("Failed to convert rem to remstr, probably out of memory.");
    });
    if (cached == null) {
        cached = engine.sdl.TTF_OpenFont("/usr/share/fonts/open-sans/OpenSans-Bold.ttf", @intCast(engine.layout.getPixelsForRem(requested_rem)));
        if (cached == null) {
            @panic(try std.fmt.allocPrint(allocator, "failed to open font: {s}", .{engine.sdl.SDL_GetError()}));
        }
        font_cache.put(requested_rem, cached.?) catch |err| {
            @panic(try std.fmt.allocPrint(allocator, "failed to cache font: {s}", .{err}));
        };
    }
    return cached.?;
}
