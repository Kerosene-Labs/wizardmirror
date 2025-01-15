const component = @import("../component.zig");

const Direction = enum {
    Vertical,
    Horizontal,
};

const Box = struct {
    children: component.Component,
    direction: Direction,
    padding: u8,
    margin: u8,
};
