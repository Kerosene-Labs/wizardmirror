const engine = @import("engine");
const std = @import("std");

// constants
const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
const allocator = std.heap.page_allocator;

// stores
const contentStore: ?*engine.state.StringStore = null;

pub const metadata = engine.component.ComponentMetadata{ .layer = 1, .name = "headlines", .render = render, .initialize = initialize };

pub fn initialize() engine._error.EngineError!void {
    // initialize our content store
    contentStore = engine.state.StringStore{ .susbcriptions = std.ArrayList().init(allocator) };
    engine.sdl.SDL_Log("Initialized component 'headlines'");
}

pub fn render() engine._error.EngineError!void {
    const surface = engine.sdl.TTF_RenderText_Solid(engine.ttfFont, "Distressing Survey Finds Most U.S. Citizens Unable To Name All 340 Million Americans", color);
    if (surface == null) {
        engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.TTF_GetError());
        return engine._error.EngineError.TTFError;
    }
    const textTexture = engine.sdl.SDL_CreateTextureFromSurface(engine.sdlRenderer, surface);
    if (textTexture == null) {
        engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
        return engine._error.EngineError.TTFError;
    }
    const rect = engine.sdl.SDL_Rect{ .x = 0, .y = 0, .w = surface.*.w, .h = surface.*.h };
    const err = engine.sdl.SDL_RenderCopy(engine.sdlRenderer, textTexture, null, &rect);
    if (err != 0) {
        engine.sdl.SDL_Log("SDL Error: %s", engine.sdl.SDL_GetError());
        return engine._error.EngineError.TTFError;
    }
}

pub fn deinitialize() engine._error.EngineError!void {
    // todo teardown
}
