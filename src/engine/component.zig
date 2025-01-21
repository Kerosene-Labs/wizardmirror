const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

/// A wrapper on top of the actual components. Contains handy pointers to our lifecycle objects.
pub const Component = struct {
    name: [:0]const u8,
    init_ptr: *const fn () anyerror!void,
    render_ptr: *const fn () anyerror!void,
    deinit_ptr: *const fn () anyerror!void,
};

/// Compile a given type to a `Component`. Performs comptime analysis reflection to store pointers to all lifecycle objects.
pub fn compile(comptime component: anytype) Component {
    comptime {
        const component_name = @typeName(component);
        const component_info = @typeInfo(component);

        var init_ptr: ?*const fn () anyerror!void = null;
        var render_ptr: ?*const fn () anyerror!void = null;
        var deinit_ptr: ?*const fn () anyerror!void = null;
        switch (component_info) {
            .Struct => |struct_info| {
                for (struct_info.decls) |decl| {
                    if (std.mem.eql(u8, decl.name, "init")) {
                        init_ptr = component.init;
                    } else if (std.mem.eql(u8, decl.name, "render")) {
                        render_ptr = component.render;
                    } else if (std.mem.eql(u8, decl.name, "deinit")) {
                        deinit_ptr = component.deinit;
                    }
                }
            },
            else => {
                @compileError("Unable to compile component; we expected a concrete struct (did you accidentally pass an instance?)");
            },
        }

        if (init_ptr == null or render_ptr == null or deinit_ptr == null) {
            @compileLog("init_ptr:", init_ptr, "render_ptr:", render_ptr, "deinit_ptr:", deinit_ptr);
            @compileError("Expected init, render, and deinit functions on component!");
        }

        return Component{
            .name = component_name,
            .init_ptr = init_ptr.?,
            .render_ptr = render_ptr.?,
            .deinit_ptr = deinit_ptr.?,
        };
    }
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
pub fn initAll(components: []const Component) !void {
    for (components) |component| {
        try init_recursively(component);
    }
}

fn render_recursively(to_render: Component) !void {
    try to_render.render_ptr();
    // if (to_render.children != null) {
    //     for (to_render.children.?.items) |child| {
    //         try render_recursively(child);
    //     }
    // }
}

/// Iterate over all components, render them
pub fn renderAll(components: []const Component) !void {
    for (components) |component| {
        try render_recursively(component);
    }
}

/// Initialize a Component and its children
fn deinit_recursively(component: Component) !void {
    try component.deinit_ptr();
    // if (to_deinitialize.children != null) {
    //     for (to_deinitialize.children.?.items) |child| {
    //         try deinit_recursively(child);
    //     }
    // }
}

/// Iterate over all components, render them
pub fn deinitAll(components: []const Component) !void {
    for (components) |component| {
        try deinit_recursively(component);
    }
}
