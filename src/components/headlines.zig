const engine = @import("engine");
const std = @import("std");

// constants
const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
const allocator = std.heap.page_allocator;

// stores
var contentStore: ?engine.state.StringStore = null;

// dependents
var surface: [*c]engine.sdl.SDL_Surface = null;

pub const metadata = engine.component.ComponentMetadata{ .layer = 1, .name = "headlines", .render = render, .initialize = initialize };

// callback for when the content store's value is changed
pub fn contentChanged() engine._error.EngineError!void {
    surface = engine.sdl.TTF_RenderText_Solid(engine.ttfFont, contentStore.?.value.ptr, color);
}

pub fn initialize() engine._error.EngineError!void {
    contentStore = try engine.state.StringStore.init("Distressing Survey Finds Most U.S. Citizens Unable To Name All 340 Million Americans"[0..], contentChanged);
    engine.sdl.SDL_Log("Initialized headlines component");
}

pub fn render() engine._error.EngineError!void {
    if (surface == null) {
        return;
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
    allocator.destroy();
}
