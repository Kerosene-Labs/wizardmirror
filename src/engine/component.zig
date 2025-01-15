const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

pub const Component = struct {
    name: [:0]const u8,
    children: []const u8,
    init_ptr: *const fn () anyerror!void,
    render_ptr: *const fn () anyerror!void,
    deinit_ptr: *const fn () anyerror!void,
};

/// Compile a given type to a Component. We'll try searching for init, render, and deinit functions and store a type name.
pub fn compile(comptime T: type) !Component {
    const component_name = @typeName(T);

    // if we have any children, compile them

    // const children_item_type = @typeInfo(children);
    // std.debug.print("{s}", children_item_type.Type);

    // function pointers
    if (!@hasDecl(T, "init")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `init` method does not exist.", .{component_name}));
    }
    const init_ptr: *const fn () anyerror!void = @field(T, "init");

    if (!@hasDecl(T, "render")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `render` method does not exist.", .{component_name}));
    }
    const render_ptr: *const fn () anyerror!void = @field(T, "render");

    if (!@hasDecl(T, "deinit")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `deinit` method does not exist.", .{component_name}));
    }
    const deinit_ptr: *const fn () anyerror!void = @field(T, "deinit");

    return Component{
        .name = @typeName(T),
        .children = "",
        .init_ptr = init_ptr,
        .render_ptr = render_ptr,
        .deinit_ptr = deinit_ptr,
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
