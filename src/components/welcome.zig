const engine = @import("engine");
const std = @import("std");

pub fn render() engine._error.EngineError!void {
    try engine.log.info("debug");
}
pub const component = engine.component.Component{ .layer = 1, .name = "welcome", .render = render };
