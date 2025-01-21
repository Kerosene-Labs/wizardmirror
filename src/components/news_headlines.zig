const engine = @import("engine");
const std = @import("std");

const Headline = struct {
    heading: []const u8,
    subheading: []const u8,
};
const HeadlineStore = engine.state.Store(Headline);
var content: ?HeadlineStore = null;

pub const MainHeadline = struct {
    pub fn init() !void {
        // children = std.ArrayList(engine.component.Component).init(std.heap.page_allocator);
        engine.sdl.SDL_Log("MainHeadling component initialized!");
    }

    pub fn render() !void {}

    pub fn deinit() !void {
        engine.sdl.SDL_Log("MainHeadline component de-initialized!");
    }
};
