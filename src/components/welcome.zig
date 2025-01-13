const engine = @import("engine");
const std = @import("std");

pub fn render() engine._error.EngineError!void {
    // set our color
    var err = engine.sdl.SDL_SetRenderDrawColor(engine.sdlRenderer, 0, 0, 255, 255);
    if (err != 0) {
        return engine._error.EngineError.SDLError;
    }

    // clear our renderer
    err = engine.sdl.SDL_RenderClear(engine.sdlRenderer);
    if (err != 0) {
        return engine._error.EngineError.SDLError;
    }

    engine.sdl.SDL_RenderPresent(engine.sdlRenderer);
    if (err != 0) {
        return engine._error.EngineError.SDLError;
    }
}

pub fn initialize() engine._error.EngineError!void {
    try engine.log.info("initialized 'welcome'");
}

pub const component = engine.component.Component{ .layer = 1, .name = "welcome", .render = render, .initialize = initialize };
