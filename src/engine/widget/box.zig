const component = @import("../component.zig");

const Direction = enum {
    Vertical,
    Horizontal,
};

const Box = struct {
    pub const direction: Direction = Direction.Horizontal;
    pub const padding: u64 = 0;
    pub const margin: u64 = 0;
    pub const width: u64 = 0;
    pub const height: u64 = 0;

    pub fn init() !void {}
    pub fn render() !void {}
    pub fn deinit() !void {}
};
