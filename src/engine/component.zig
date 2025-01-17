const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

/// A wrapper on top of the actual components. Contains handy pointers to our lifecycle objects.
pub const Component = struct {
    name: [:0]const u8,
    children: []const Component,
    init_ptr: *const fn () anyerror!void,
    render_ptr: *const fn () anyerror!void,
    deinit_ptr: *const fn () anyerror!void,
};

/// Compile a given type to a `Component`. Performs comptime analysis reflection to store pointers to all lifecycle objects.
pub fn compile(comptime component_instance: anytype) Component {
    const component_type = @TypeOf(component_instance);
    const component_name = @typeName(component_type);

    if (component_type == type) {
        @compileError("Failed to compile a component. You've passed in a type, while we expect an instance of your type. (hint: append a {} to the end of your component type to make it an instance");
    }
    // children
    if (!@hasField(component_type, "children")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `children` slice does not exist.", .{component_name}));
    }
    const children: []const Component = @field(component_instance, "children");

    // function pointers
    if (!@hasDecl(component_type, "init")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `init` method does not exist.", .{component_name}));
    }
    const init_ptr: *const fn () anyerror!void = @field(component_type, "init");

    if (!@hasDecl(component_type, "render")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `render` method does not exist.", .{component_name}));
    }
    const render_ptr: *const fn () anyerror!void = @field(component_type, "render");

    if (!@hasDecl(component_type, "deinit")) {
        @compileError(std.fmt.comptimePrint("Failed to compile the '{s}' component as the `deinit` method does not exist.", .{component_name}));
    }
    const deinit_ptr: *const fn () anyerror!void = @field(component_type, "deinit");

    return Component{
        .name = component_name,
        .children = children,
        .init_ptr = init_ptr,
        .render_ptr = render_ptr,
        .deinit_ptr = deinit_ptr,
    };
}

/// Iterate over all components, initialize them
pub fn initAll(initContext: engine.InitializationContext) !void {
    for (initContext.components) |component| {
        try component.init_ptr();
    }
}

/// Iterate over all components, render them
pub fn renderAll(init_context: engine.InitializationContext) !void {
    for (init_context.components) |component| {
        // todo implement layering here
        try component.render_ptr();
    }
}

/// Iterate over all components, render them
pub fn deinitAll(init_context: engine.InitializationContext) !void {
    for (init_context.components) |component| {
        try component.deinit_ptr();
    }
}
