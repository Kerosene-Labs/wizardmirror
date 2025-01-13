const engine = @import("engine");
const std = @import("std");

pub fn render() engine._error.EngineError!void {
    // set our color
    const err = engine.sdl.SDL_SetRenderDrawColor(engine.sdlRenderer, 0, 0, 0, 255);
    if (err != 0) {
        return engine._error.EngineError.SDLError;
    }

    engine.sdl.SDL_RenderPresent(engine.sdlRenderer);
    if (err != 0) {
        return engine._error.EngineError.SDLError;
    }
}

pub fn initialize() engine._error.EngineError!void {
    engine.sdl.SDL_Log("Initialized component 'bg'");
}

pub const component = engine.component.Component{ .layer = 1, .name = "bg", .render = render, .initialize = initialize };
