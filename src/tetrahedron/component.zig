const tetrahedron = @import("root.zig");
const errors = @import("errors.zig");
const std = @import("std");

const log = std.log.scoped(.tetrahedron_component);

var registry = std.ArrayList(Component).init(std.heap.page_allocator);

// our lifecycle functions
pub const InitLifecycleFn = *const fn () anyerror!void;
pub const RenderLifecycleFn = *const fn () anyerror!void;
pub const DeinitLifecycleFn = *const fn () anyerror!void;

/// A wrapper on top of the actual components. Contains handy pointers to our lifecycle objects.
pub const Component = struct {
    name: []const u8,
    init_ptr: InitLifecycleFn,
    render_ptr: RenderLifecycleFn,
    deinit_ptr: DeinitLifecycleFn,
};

/// Register a component.
pub fn register(
    name: []const u8,
    init: InitLifecycleFn,
    render: RenderLifecycleFn,
    deinit: DeinitLifecycleFn,
) !void {
    log.info("registered component '{s}'", .{name});
    try registry.append(Component{
        .name = name,
        .init_ptr = init,
        .render_ptr = render,
        .deinit_ptr = deinit,
    });
}

/// Iterate over all components, initialize them
pub fn initAll() !void {
    log.info("beginning initialization of components", .{});
    for (registry.items) |component| {
        log.info(" - '{s}' : calling init()", .{component.name});
        try component.init_ptr();
    }
    log.info("component initialization complete", .{});
}

/// Iterate over all components, render them
pub fn renderAll() !void {
    for (registry.items) |component| {
        try component.render_ptr();
    }
}

/// Iterate over all components, render them
pub fn deinitAll() !void {
    log.info("beginning de-initialization of components", .{});
    for (registry.items) |component| {
        log.info(" - '{s}' - deinitializing", .{component.name});
        try component.deinit_ptr();
    }
    log.info("beginning de-initialization of components", .{});
}
