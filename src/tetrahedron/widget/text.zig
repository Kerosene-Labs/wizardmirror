const component = @import("../component.zig");
const tetrahedron = @import("../root.zig");
const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub const default_color = tetrahedron.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

/// Represents the text the user is requesting
const CacheKey = struct {
    text: []const u8,
    font_size: tetrahedron.layout.FloatPx,
    font_weight: tetrahedron.font.FontWeight,
};

/// Represents a cacheable group of a surface, texture and rect.
const Renderable = struct {
    surface: *tetrahedron.sdl.SDL_Surface,
    texture: *tetrahedron.sdl.SDL_Texture,
    rect: *tetrahedron.sdl.SDL_Rect,
    last_accessed: u64,

    fn deinit(self: @This()) !void {
        try allocator.free(self.rect);
        tetrahedron.sdl.SDL_FreeSurface(self.surface);
        tetrahedron.sdl.SDL_DestroyTexture(self.texture);
    }
};

/// HashMap Context
const TextContextHashMapContext = struct {
    pub fn hash(_: @This(), key: CacheKey) u64 {
        var hasher = std.hash.Wyhash.init(0);
        const bit_font_size: u32 = @bitCast(key.font_size);
        hasher.update(std.mem.asBytes(&bit_font_size));
        hasher.update(key.font_weight);
        hasher.update(key.text);
        return hasher.final();
    }

    pub fn eql(_: @This(), a: CacheKey, b: CacheKey) bool {
        return a.font_size == b.font_size and std.mem.eql(u8, a.font_weight, b.font_weight) and std.mem.eql(u8, a.text, b.text);
    }
};

var cache = std.HashMap(CacheKey, *Renderable, TextContextHashMapContext, std.hash_map.default_max_load_percentage).init(allocator);

/// Pre-made text rendering component. Lazy caching mechanism for surfaces, textures and rects.
/// Automatically subscribes to the given `StringStore`.
pub fn TextLine(text_store: *tetrahedron.state.StringStore, size: tetrahedron.layout.Rem, weight: tetrahedron.font.FontWeight, color: tetrahedron.sdl.SDL_Color, x: tetrahedron.layout.Rem, y: tetrahedron.layout.Rem) type {
    const _type = struct {
        /// A renderable in this context is the shared set of all SDL objects we need to make this appear on screen
        fn getRenderable(text: []const u8) !?*Renderable {
            // if our text wasn't provided, skip rendering
            if (std.mem.eql(u8, text, "")) {
                return null;
            }

            // set our text context
            const cache_key = CacheKey{
                .text = text,
                .font_size = tetrahedron.layout.getFloatPixelsFromRem(size),
                .font_weight = weight,
            };

            // get our cache candidate, ensure its valid
            const candidate = cache.get(cache_key);
            if (candidate != null and (tetrahedron.sdl.SDL_GetTicks() - candidate.?.last_accessed) <= 5_000) {
                return candidate.?;
            }

            const c_text = try allocator.dupeZ(u8, text);
            defer allocator.free(c_text);

            const surface = tetrahedron.sdl.TTF_RenderText_Blended_Wrapped(try tetrahedron.font.getFont(size, weight), c_text, 0, color, 400);
            if (surface == null) {
                std.log.err("failed to render text: {s}", .{tetrahedron.sdl.SDL_GetError()});
                return tetrahedron.errors.SDLError.RenderTextFailed;
            }

            const texture = tetrahedron.sdl.SDL_CreateTextureFromSurface(tetrahedron.lifecycle.sdl_renderer, surface);
            if (texture == null) {
                std.log.err("failed to render text: {s}", .{tetrahedron.sdl.SDL_GetError()});
                return tetrahedron.errors.SDLError.CreateTextureFromSurfaceFailed;
            }

            const rect = try allocator.create(tetrahedron.sdl.SDL_Rect);
            rect.* = tetrahedron.sdl.SDL_Rect{
                .x = x,
                .y = y,
                .w = surface.*.w,
                .h = surface.*.h,
            };

            // create our renderable
            const pair = try allocator.create(Renderable);
            pair.* = Renderable{
                .surface = surface,
                .texture = texture.?,
                .rect = rect,
                .last_accessed = tetrahedron.sdl.SDL_GetTicks(),
            };
            try cache.put(cache_key, pair);
            return pair;
        }

        pub fn render() !void {
            const to_render = try getRenderable(text_store.get());
            if (to_render) |non_null_renderable| {
                if (!tetrahedron.sdl.SDL_RenderTexture(
                    tetrahedron.lifecycle.sdl_renderer,
                    non_null_renderable.texture,
                    null,
                    @ptrCast(non_null_renderable.rect),
                )) {
                    std.log.err("sdl error: {s}", .{tetrahedron.sdl.SDL_GetError()});
                    return tetrahedron.errors.SDLError.RenderCopyFailed;
                }
            }
        }
    };
    return _type;
}
