const log = @import("log.zig");
const _error = @import("error.zig");

/// A component to be rendered
const Component = struct { name: []const u8, layer: u8, render: fn () _error.EngineError!void };
