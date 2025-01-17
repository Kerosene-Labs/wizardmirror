const component = @import("../component.zig");
const engine = @import("../lib.zig");
const std = @import("std");

var surfaces = std.StringHashMap([*c]engine.sdl.SDL_Surface).init(std.heap.page_allocator);

/// Pre-made text rendering component. Caches SDL_Surface's based on text input.
pub const TextLine = struct {
    children: []const engine.component.Component = &.{},
    text: []const u8,
    x: i32,
    y: i32,
    color: ?engine.sdl.SDL_Color,

    pub fn make_widget(
        text: []const u8,
        x: i32,
        y: i32,
        color: ?engine.sdl.SDL_Color,
    ) TextLine {
        return TextLine{
            .color = color,
            .text = text,
            .x = x,
            .y = y,
        };
    }

    pub fn init() !void {
        if (self.color == null) {
            self.color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
        }
    }

    pub fn render(_: engine.sdl.SDL_Rect) !void {
        // try getting our surface
        var surface = surfaces.get(self.text);
        if (surface == null) {
            const new_surface = engine.sdl.TTF_RenderText_Blended(engine.lifecycle.ttf_font, self.text.ptr, self.color);
            try surfaces.put(self.text, new_surface);
            surface = new_surface;
        }

        // create our texture
        const textTexture = engine.sdl.SDL_CreateTextureFromSurface(engine.lifecycle.sdl_renderer, surface.?);
        if (textTexture == null) {
            engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
            return engine.errors.SDLError.CreateTextureFromSurfaceFailed;
        }
        const surface_w = @divTrunc(surface.?.*.w, 2);
        const surface_h = @divTrunc(surface.?.*.h, 2);
        const rect = engine.sdl.SDL_Rect{ .x = @intCast(self.x), .y = @intCast(self.y), .w = surface_w, .h = surface_h };
        const err = engine.sdl.SDL_RenderCopy(engine.lifecycle.sdl_renderer, textTexture, null, &rect);
        if (err != 0) {
            engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
            return engine.errors.SDLError.RenderCopyFailed;
        }
    }

    pub fn deinit() !void {}
};

// pub fn TextLine(text: []const u8, x: i32, y: i32, color: ?engine.sdl.SDL_Color) type;
