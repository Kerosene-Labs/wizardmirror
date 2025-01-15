const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

pub const Component = struct {
    name: [:0]const u8,
    init_ptr: *const fn () anyerror!void,
    render_ptr: *const fn () anyerror!void,
    deinit_ptr: *const fn () anyerror!void,
};

/// *loosely* "Compile" a given type to a Component. We'll try searching for init, render, and deinit functions and store a type name.
pub fn compile(comptime T: type) !Component {
    // function pointers
    const init_ptr: ?*const fn () anyerror!void = @field(T, "init");
    const render_ptr: ?*const fn () anyerror!void = @field(T, "render");
    const deinit_ptr: ?*const fn () anyerror!void = @field(T, "deinit");

    // if any of our function pointers are null, return an error
    if (init_ptr == null) {
        @compileError("Incorrect component, init_ptr is null");
    }
    if (render_ptr == null) {
        @compileError("Incorrect component, render_ptr is null");
    }
    if (deinit_ptr == null) {
        @compileError("Incorrect component, deinit_ptr is null");
    }

    return Component{
        .name = @typeName(T),
        .init_ptr = init_ptr.?,
        .render_ptr = render_ptr.?,
        .deinit_ptr = deinit_ptr.?,
    };
}

/// Iterate over all components, initialize them
pub fn initAll(initContext: engine.InitializationContext) !void {
    for (initContext.components.items) |component| {
        try component.init_ptr();
    }
}

/// Iterate over all components, render them
pub fn renderAll(init_context: engine.InitializationContext) !void {
    for (init_context.components.items) |component| {
        // todo implement layering here
        try component.render_ptr();
    }
}

/// Iterate over all components, render them
pub fn deinitAll(init_context: engine.InitializationContext) !void {
    for (init_context.components.items) |component| {
        try component.deinit_ptr();
    }
}
