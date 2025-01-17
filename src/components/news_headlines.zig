const engine = @import("engine");
const std = @import("std");

const Headline = struct {
    heading: []const u8,
    subheading: []const u8,
};
const HeadlineStore = engine.state.Store(Headline);
var content: ?HeadlineStore = null;

pub const Subline = struct {
    children: []const engine.component.Component = &.{},

    pub fn init() !void {
        engine.sdl.SDL_Log("Subline component initialized!");
    }

    pub fn render(_: engine.sdl.SDL_Rect) !void {}

    pub fn deinit() !void {
        engine.sdl.SDL_Log("Subline component de-initialized!");
    }
};

pub const MainHeadline = struct {
    children: []const engine.component.Component = &.{engine.component.compile(Subline{})},

    const color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    var surface: [*c]engine.sdl.SDL_Surface = null;

    pub fn do_carousel(_: u32, _: ?*anyopaque) callconv(.C) u32 {
        return 0;
    }

    pub fn init() !void {
        // const sdlTimer = engine.sdl.SDL_AddTimer(1000, do_carousel, null);
        // if (sdlTimer == 0) {
        //     return engine.errors.SDLError.CreateTimerError;
        // }
        // content = try HeadlineStore.init(Headline{ .heading = "Test", .subheading = "Lorem ipsum" });
        // try content.?.subscribe(content_changed);
        engine.sdl.SDL_Log("MainHeadling component initialized!");
    }

    pub fn render(bounds: engine.sdl.SDL_Rect) !void {
        const hello_world = engine.widget.text.TextLine("Hello, World!");
        try hello_world.render(bounds);
    }

    pub fn deinit() !void {
        engine.sdl.SDL_Log("MainHeadline component de-initialized!");
    }
};
