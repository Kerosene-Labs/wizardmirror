const component = @import("../component.zig");
const engine = @import("../lib.zig");
const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var cache = std.StringHashMap(*Renderable).init(allocator);

const default_color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

/// Represents a cacheable pair of surface, texture and rect.
const Renderable = struct {
    surface: *engine.sdl.SDL_Surface,
    texture: *engine.sdl.SDL_Texture,
    rect: *engine.sdl.SDL_Rect,
    last_accessed: u32,

    fn deinit(self: @This()) !void {
        try allocator.free(self.rect);
        engine.sdl.SDL_FreeSurface(self.surface);
        engine.sdl.SDL_DestroyTexture(self.texture);
    }
};

/// Pre-made text rendering component. Lazy caching mechanism for surfaces, textures and rects.
/// Automatically subscribes to the given `StringStore`.
pub fn TextLine(text_store: *engine.state.StringStore, weight: engine.font.FontWeight, x: i64, y: i64) type {
    const _type = struct {
        /// A renderable in this context is the shared set of all SDL objects we need to make this appear on screen
        fn getRenderable(color: engine.sdl.SDL_Color, text: []const u8) !?*Renderable {
            // if our text was provided, skip rendering
            if (std.mem.eql(u8, text, "")) {
                return null;
            }

            // get our cache candidate, ensure its valid
            const candidate = cache.get(text);
            if (candidate != null and (engine.sdl.SDL_GetTicks() - candidate.?.last_accessed) <= 5_000) {
                return candidate.?;
            }

            const c_text = try allocator.dupeZ(u8, text);
            defer allocator.free(c_text);

            const surface = engine.sdl.TTF_RenderText_Blended(try engine.font.getFont(1.0, weight), c_text, color);
            if (surface == null) {
                engine.sdl.SDL_LogError(engine.sdl.SDL_LOG_CATEGORY_APPLICATION, "failed to render text: %s", engine.sdl.SDL_GetError());
                return engine.errors.SDLError.RenderTextFailed;
            }

            const texture = engine.sdl.SDL_CreateTextureFromSurface(engine.lifecycle.sdl_renderer, surface);
            if (texture == null) {
                return engine.errors.SDLError.CreateTextureFromSurfaceFailed;
            }

            const surface_w = @divTrunc(surface.*.w, 2);
            const surface_h = @divTrunc(surface.*.h, 2);
            const rect = try allocator.create(engine.sdl.SDL_Rect);
            rect.* = engine.sdl.SDL_Rect{
                .x = @intCast(x),
                .y = @intCast(y),
                .w = surface_w,
                .h = surface_h,
            };

            // create our renderable
            const pair = try allocator.create(Renderable);
            pair.* = Renderable{
                .surface = surface,
                .texture = texture.?,
                .rect = rect,
                .last_accessed = engine.sdl.SDL_GetTicks(),
            };
            try cache.put(text, pair);
            return pair;
        }

        pub fn render() !void {
            const to_render = try getRenderable(default_color, text_store.get());
            if (to_render != null) |non_null_renderable| {
                const err = engine.sdl.SDL_RenderCopy(engine.lifecycle.sdl_renderer, non_null_renderable.texture, null, non_null_renderable.rect);
                if (err != 0) {
                    engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
                    return engine.errors.SDLError.RenderCopyFailed;
                }
            }
        }
    };
    return _type;
}
