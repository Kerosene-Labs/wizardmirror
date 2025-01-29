const engine = @import("lib.zig");
const errors = @import("errors.zig");
const std = @import("std");

var registry = std.ArrayList(Component).init(std.heap.page_allocator);

/// A wrapper on top of the actual components. Contains handy pointers to our lifecycle objects.
pub const Component = struct {
    name: []const u8,
    init_ptr: *const fn () anyerror!void,
    render_ptr: *const fn () anyerror!void,
    deinit_ptr: *const fn () anyerror!void,
};

/// Register a component.
pub fn register(
    name: []const u8,
    init: *const fn () anyerror!void,
    render: *const fn () anyerror!void,
    deinit: *const fn () anyerror!void,
) !void {
    std.log.info("registered component '{s}'", .{name});
    try registry.append(Component{
        .name = name,
        .init_ptr = init,
        .render_ptr = render,
        .deinit_ptr = deinit,
    });
}

/// Iterate over all components, initialize them
pub fn initAll() !void {
    std.log.info("beginning initialization of components", .{});
    for (registry.items) |component| {
        std.log.info(" - '{s}' : calling init()", .{component.name});
        try component.init_ptr();
    }
    std.log.info("component initialization complete", .{});
}

/// Iterate over all components, render them
pub fn renderAll() !void {
    for (registry.items) |component| {
        try component.render_ptr();
    }
}

/// Iterate over all components, render them
pub fn deinitAll() !void {
    std.log.info("beginning de-initialization of components", .{});
    for (registry.items) |component| {
        std.log.info(" - '{s}' - deinitializing", .{component.name});
        try component.deinit_ptr();
    }
    std.log.info("beginning de-initialization of components", .{});
}
