const component = @import("../component.zig");

const Direction = enum {
    Vertical,
    Horizontal,
};

const Box = struct {
    pub const children: []const component.Component = .{};
    pub const direction: Direction = Direction.Horizontal;
    pub const padding: u8;
    pub const margin: u8;
};
