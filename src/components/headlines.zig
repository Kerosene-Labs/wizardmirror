const engine = @import("engine");
const std = @import("std");

// constants
const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
const allocator = std.heap.page_allocator;

// stores
var contentStore: ?engine.state.StringStore = null;

// store affected values (useEffect..?)
var surface: [*c]engine.sdl.SDL_Surface = null;

pub const metadata = engine.component.ComponentMetadata{ .layer = 1, .name = "headlines", .render = render, .initialize = initialize };

pub fn contentChanged() engine._error.EngineError!void {
    surface = engine.sdl.TTF_RenderText_Solid(engine.ttfFont, contentStore.?.value.ptr, color);
}

pub fn initialize() engine._error.EngineError!void {
    // initialize our content store
    contentStore = engine.state.StringStore{ .susbcriptions = std.ArrayList(*const fn () engine._error.EngineError!void).init(allocator), .value = "Distressing Survey Finds Most U.S. Citizens Unable To Name All 340 Million Americans" };
    try contentStore.?.subscribe(contentChanged);

    // set a timer (for fun :3)
    _ = engine.sdl.SDL_AddTimer(1000, refreshContent, null);
    engine.sdl.SDL_Log("Initialized component 'headlines'");
}

pub fn refreshContent(x: u32, y: ?*anyopaque) callconv(.C) u32 {
    _ = x;
    _ = y;
    const rand = std.crypto.random.boolean();
    if (rand) {
        contentStore.?.update("Headline 1"[0..]) catch {};
    } else {
        contentStore.?.update("Headline 2"[0..]) catch {};
    }
    _ = engine.sdl.SDL_AddTimer(1000, refreshContent, null);

    return 0;
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
    // todo teardown
}
