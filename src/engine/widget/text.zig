const component = @import("../component.zig");
const engine = @import("../lib.zig");
const std = @import("std");

var surfaces = std.StringHashMap([*c]engine.sdl.SDL_Surface).init(std.heap.page_allocator);

/// Pre-made text rendering component. Caches SDL_Surface's based on text input.
pub fn TextLine(text_store: *engine.state.StringStore, x: i32, y: i32) type {
    return struct {
        var current_surface: ?[*c]engine.sdl.SDL_Surface = null;

        pub fn init() !void {
            try text_store.subscribe(text_changed);
        }

        fn text_changed() !void {
            // try getting our surface
            const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
            var surface = surfaces.get(text_store.value);
            if (surface == null) {
                const new_surface = engine.sdl.TTF_RenderText_Blended(engine.lifecycle.ttf_font, text_store.value.ptr, color);
                try surfaces.put(text_store.value, new_surface);
                surface = new_surface;
            }
            current_surface = surface;
        }

        pub fn render() !void {
            // create our texture
            if (current_surface == null) {
                return;
            }
            const textTexture = engine.sdl.SDL_CreateTextureFromSurface(engine.lifecycle.sdl_renderer, current_surface.?);
            if (textTexture == null) {
                engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
                return engine.errors.SDLError.CreateTextureFromSurfaceFailed;
            }
            const surface_w = @divTrunc(current_surface.?.*.w, 2);
            const surface_h = @divTrunc(current_surface.?.*.h, 2);
            const rect = engine.sdl.SDL_Rect{ .x = @intCast(x), .y = @intCast(y), .w = surface_w, .h = surface_h };
            const err = engine.sdl.SDL_RenderCopy(engine.lifecycle.sdl_renderer, textTexture, null, &rect);
            if (err != 0) {
                engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
                return engine.errors.SDLError.RenderCopyFailed;
            }
        }

        pub fn deinit() !void {}
    };
}
