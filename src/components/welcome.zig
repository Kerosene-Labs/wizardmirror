const engine = @import("engine");
const std = @import("std");

pub fn render() engine._error.EngineError!void {}

pub fn initialize() engine._error.EngineError!void {
    engine.sdl.SDL_Log("Initialized component 'welcome'");
}

pub const component = engine.component.Component{ .layer = 1, .name = "welcome", .render = render, .initialize = initialize };
