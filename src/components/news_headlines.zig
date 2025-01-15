const engine = @import("engine");
const std = @import("std");

// constants
const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

// stores
var content: ?engine.state.StringStore = null;

// dependents
var surface: [*c]engine.sdl.SDL_Surface = null;

fn contentChanged() !void {
    surface = engine.sdl.TTF_RenderText_Blended(engine.lifecycle.ttf_font, content.?.value.ptr, color);
}

pub fn do_carousel(_: u32, _: ?*anyopaque) callconv(.C) u32 {
    content.?.update("Distressing Survey Finds Most U.S. Citizens Unable To Name All 340 Million Americans"[0..]) catch {
        return 1;
    };
    return 0;
}

pub const MainHeadline = struct {
    pub fn init() !void {
        const sdlTimer = engine.sdl.SDL_AddTimer(1000, do_carousel, null);
        if (sdlTimer == 0) {
            return engine.errors.SDLError.CreateTimerError;
        }
        content = try engine.state.StringStore.init("..."[0..]);
        try content.?.subscribe(contentChanged);
        engine.sdl.SDL_Log("MainHeadling component initialized!");
    }

    pub fn render() !void {
        if (surface == null) {
            return;
        }
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

    pub fn deinit() !void {
        engine.sdl.SDL_Log("MainHeadline component de-initialized!");
    }
};
