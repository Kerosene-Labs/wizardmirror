const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

/// A wrapper on top of the actual components. Contains handy pointers to our lifecycle objects.
pub const Component = struct {
    name: [:0]const u8,
    id: [:0]const u8,
    init_ptr: *const fn () anyerror!void,
    render_ptr: *const fn () anyerror!void,
    deinit_ptr: *const fn () anyerror!void,
    source: type,
};

/// Compile a given type to a `Component`. Performs comptime analysis reflection to store pointers to all lifecycle objects.
pub fn compile(comptime component: anytype) Component {
    const component_type = @TypeOf(component);
    const component_name = @typeName(component_type);

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
        .init_ptr = init_ptr,
        .render_ptr = render_ptr,
        .deinit_ptr = deinit_ptr,
        .source = component,
    };
}

/// Initialize a Component and its children
fn init_recursively(to_initialize: engine.component.Component) !void {
    try to_initialize.init_ptr();
    // if (to_initialize.children != null) {
    //     for (to_initialize.children.?.items) |child| {
    //         try init_recursively(child);
    //     }
    // }
}

/// Iterate over all components, initialize them
pub fn initAll(initContext: engine.InitializationContext) !void {
    for (initContext.components) |component| {
        try init_recursively(component);
    }
}

fn render_recursively(to_render: engine.component.Component) !void {
    try to_render.render_ptr();
    // if (to_render.children != null) {
    //     for (to_render.children.?.items) |child| {
    //         try render_recursively(child);
    //     }
    // }
}

/// Iterate over all components, render them
pub fn renderAll(init_context: engine.InitializationContext) !void {
    for (init_context.components) |component| {
        try render_recursively(component);
    }
}

/// Initialize a Component and its children
fn deinit_recursively(to_deinitialize: engine.component.Component) !void {
    try to_deinitialize.deinit_ptr();
    // if (to_deinitialize.children != null) {
    //     for (to_deinitialize.children.?.items) |child| {
    //         try deinit_recursively(child);
    //     }
    // }
}

/// Iterate over all components, render them
pub fn deinitAll(init_context: engine.InitializationContext) !void {
    for (init_context.components) |component| {
        try deinit_recursively(component);
    }
}
