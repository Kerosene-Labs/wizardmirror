const component = @import("../component.zig");
const engine = @import("../lib.zig");
const std = @import("std");

const default_color = engine.sdl.SDL_Color{ .r = 0, .g = 0, .b = 0, .a = 255 };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const allocator = gpa.allocator();

const Renderable = struct {
    surface: *engine.sdl.SDL_Surface,
    texture: *engine.sdl.SDL_Texture,
    rect: *engine.sdl.SDL_Rect,

    fn deinit(self: @This()) !void {
        try allocator.free(self.rect);
        engine.sdl.SDL_FreeSurface(self.surface);
        engine.sdl.SDL_DestroyTexture(self.texture);
    }
};

var cache = std.StringHashMap(*Renderable).init(allocator);

/// Pre-made text rendering component. Shares a global caching mechanism for surfaces, textures and rects.
/// Automatically subscribes to the given `StringStore`.
pub fn TextLine(text_store: *engine.state.StringStore, x: i32, y: i32) type {
    return struct {
        var to_render: ?*Renderable = null;

        pub fn init() !void {
            try text_store.subscribe(text_changed);
        }

        /// A renderable in this context is the shared set of all SDL objects we need to make this appear on screen
        fn createRenderable(color: engine.sdl.SDL_Color, text: []const u8) !*Renderable {
            const c_text = try allocator.dupeZ(u8, text);
            defer allocator.free(c_text);

            const surface = engine.sdl.TTF_RenderText_Blended(engine.lifecycle.ttf_font, c_text, color);
            if (surface == null) {
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
                .rect = @constCast(rect),
            };
            return pair;
        }

        fn text_changed() !void {
            // try getting our surface texture pair from cache
            var renderable_candidate = cache.get(text_store.value);
            if (renderable_candidate == null) {
                std.debug.print("cache miss: {s}\n", .{text_store.value});
                renderable_candidate = try createRenderable(default_color, text_store.value);
                try cache.put(text_store.value, renderable_candidate.?);
            } else {
                std.debug.print("cache hit: {s}\n", .{text_store.value});
            }
            to_render = renderable_candidate.?;
        }

        pub fn render() !void {
            // skip this itreration if we're still waiting on rendering
            if (to_render == null) {
                std.log.info("skipping render iteration", .{});
                return;
            }

            const err = engine.sdl.SDL_RenderCopy(engine.lifecycle.sdl_renderer, to_render.?.texture, null, to_render.?.rect);
            if (err != 0) {
                engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
                return engine.errors.SDLError.RenderCopyFailed;
            }
        }
    };
}
