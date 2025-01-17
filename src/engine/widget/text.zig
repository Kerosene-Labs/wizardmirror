const component = @import("../component.zig");
const engine = @import("../lib.zig");
const std = @import("std");

var surfaces = std.StringHashMap(engine.sdl.SDL_Surface).init(std.heap.page_allocator);

/// Pre-made text rendering component. Caches SDL_Surface's based on text input.
pub fn TextLine(text: []const u8) type {
    return struct {
        children: []const component.Component = &.{},

        pub fn init() !void {}

        pub fn render(_: engine.sdl.SDL_Rect) !void {
            const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

            // try getting our surface
            var surface = surfaces.get(text);
            if (surface == null) {
                surface = *engine.sdl.TTF_RenderText_Blended(engine.lifecycle.ttf_font, text.ptr, color);
                surfaces.put(text, surface);
            }

            // create our texture
            const textTexture = engine.sdl.SDL_CreateTextureFromSurface(engine.lifecycle.sdl_renderer, surface);
            if (textTexture == null) {
                engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
                return engine.errors.SDLError.CreateTextureFromSurfaceFailed;
            }
            const surface_w = @divTrunc(surface.*.w, 2);
            const surface_h = @divTrunc(surface.*.h, 2);
            const rect = engine.sdl.SDL_Rect{ .x = 0, .y = 0, .w = surface_w, .h = surface_h };
            const err = engine.sdl.SDL_RenderCopy(engine.lifecycle.sdl_renderer, textTexture, null, &rect);
            if (err != 0) {
                engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
                return engine.errors.SDLError.RenderCopyFailed;
            }
        }

        pub fn deinit() !void {}
    };
}
