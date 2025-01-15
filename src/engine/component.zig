const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

/// A component to be rendered
pub const ComponentMetadata = struct {
    name: []const u8,
    layer: u8,
    render: *const fn () anyerror!void,
    initialize: ?*const fn () anyerror!void,
};

/// Iterate over all components, initialize them
pub fn initializeAll(initContext: engine.InitializationContext) !void {
    for (initContext.components.items) |component| {
        if (component.initialize) |initialize| {
            try initialize();
        }
    }
}

/// Iterate over all components, render them
pub fn renderAll(init_context: engine.InitializationContext) !void {
    for (init_context.components.items) |component| {
        // todo implement layering here
        try component.render();
    }
}
