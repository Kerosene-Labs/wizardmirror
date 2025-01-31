const component = @import("../component.zig");
const engine = @import("../lib.zig");
const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub const default_color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

/// Represents the text the user is requesting
const CacheKey = struct {
    text: []const u8,
    font_size: engine.layout.FloatPx,
    font_weight: engine.font.FontWeight,
};

/// Represents a cacheable group of a surface, texture and rect.
const Renderable = struct {
    surface: *engine.sdl.SDL_Surface,
    texture: *engine.sdl.SDL_Texture,
    rect: *engine.sdl.SDL_Rect,
    last_accessed: u64,

    fn deinit(self: @This()) !void {
        try allocator.free(self.rect);
        engine.sdl.SDL_FreeSurface(self.surface);
        engine.sdl.SDL_DestroyTexture(self.texture);
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
pub fn TextLine(text_store: *engine.state.StringStore, size: engine.layout.Rem, weight: engine.font.FontWeight, color: engine.sdl.SDL_Color, x: engine.layout.Rem, y: engine.layout.Rem) type {
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
                .font_size = engine.layout.getFloatPixelsFromRem(size),
                .font_weight = weight,
            };

            // get our cache candidate, ensure its valid
            const candidate = cache.get(cache_key);
            if (candidate != null and (engine.sdl.SDL_GetTicks() - candidate.?.last_accessed) <= 5_000) {
                return candidate.?;
            }

            const c_text = try allocator.dupeZ(u8, text);
            defer allocator.free(c_text);

            const surface = engine.sdl.TTF_RenderText_Blended(try engine.font.getFont(size, weight), c_text, c_text.len, color);
            if (surface == null) {
                std.log.err("failed to render text: {s}", .{engine.sdl.SDL_GetError()});
                return engine.errors.SDLError.RenderTextFailed;
            }

            const texture = engine.sdl.SDL_CreateTextureFromSurface(engine.lifecycle.sdl_renderer, surface);
            if (texture == null) {
                std.log.err("failed to render text: {s}", .{engine.sdl.SDL_GetError()});
                return engine.errors.SDLError.CreateTextureFromSurfaceFailed;
            }

            const rect = try allocator.create(engine.sdl.SDL_Rect);
            rect.* = engine.sdl.SDL_Rect{
                .x = engine.layout.getPixelsForRem(x),
                .y = engine.layout.getPixelsForRem(y),
                .w = surface.*.w,
                .h = surface.*.h,
            };

            // create our renderable
            const pair = try allocator.create(Renderable);
            pair.* = Renderable{
                .surface = surface,
                .texture = texture.?,
                .rect = rect,
                .last_accessed = engine.sdl.SDL_GetTicks(),
            };
            try cache.put(cache_key, pair);
            return pair;
        }

        pub fn render() !void {
            const to_render = try getRenderable(text_store.get());
            if (to_render) |non_null_renderable| {
                if (engine.sdl.SDL_RenderTexture(
                    engine.lifecycle.sdl_renderer,
                    non_null_renderable.texture,
                    null,
                    @ptrCast(non_null_renderable.rect),
                )) {
                    std.log.err("sdl error: {s}", .{engine.sdl.SDL_GetError()});
                    return engine.errors.SDLError.RenderCopyFailed;
                }
            }
        }
    };
    return _type;
}
