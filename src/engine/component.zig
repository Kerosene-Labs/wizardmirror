const log = @import("log.zig");
const engine = @import("lib.zig");
const _error = @import("error.zig");
const std = @import("std");

/// A component to be rendered
pub const Component = struct {
    name: []const u8,
    layer: u8,
    render: *const fn () engine._error.EngineError!void,
};

pub fn renderComponents(initContext: engine.InitializationContext) engine._error.EngineError!void {
    for (initContext.components.items) |component| {
        // todo implement layering here
        try component.render();
    }
}
