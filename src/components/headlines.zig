const engine = @import("engine");
const std = @import("std");

pub fn render() engine._error.EngineError!void {}

pub fn initialize() engine._error.EngineError!void {
    try engine.log.info("initialized 'headlines'");
}

pub const component = engine.component.Component{ .layer = 1, .name = "headlines", .render = render, .initialize = initialize };
