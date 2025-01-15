// exported modules
pub const errors = @import("errors.zig");
pub const sdl = @cImport({
    @cInclude("SDL2/SDL_ttf.h");
});
pub const state = @import("state.zig");
pub const component = @import("component.zig");
pub const lifecycle = @import("lifecycle.zig");

// required internal modules
const std = @import("std");

// represents the state of our initialization
pub const InitializationContext = struct {
    components: std.ArrayList(component.Component),
};
