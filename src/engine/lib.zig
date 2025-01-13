pub const log = @import("log.zig");
pub const _error = @import("error.zig");
pub const component = @import("component.zig");
pub const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});
pub const ttf = @cImport({
    @cInclude("SDL2/SDL_ttf.h");
});
const std = @import("std");

pub var sdlRenderer: ?*sdl.SDL_Renderer = null;

pub const InitializationContext = struct {
    components: std.ArrayList(component.Component),
};

pub fn run(initContext: InitializationContext) !void {
    try log.info("welcome to wizardmirror");

    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        try log.info("unable to open window");
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "WizardMirror",
        sdl.SDL_WINDOWPOS_CENTERED,
        sdl.SDL_WINDOWPOS_CENTERED,
        800,
        600,
        sdl.SDL_WINDOW_SHOWN,
    );
    if (window == null) {
        try log.info("failed to create window");
        return _error.EngineError.SDLError;
    }
    defer sdl.SDL_DestroyWindow(window);
    try log.info("window created");

    sdlRenderer = sdl.SDL_CreateRenderer(window, -1, 0);
    defer sdl.SDL_DestroyRenderer(sdlRenderer);

    sdl.SDL_RenderPresent(sdlRenderer);
    var event: sdl.SDL_Event = undefined;

    // initialize components
    try component.initializeAll(initContext);

    // enter our main loop
    try log.info("entering main loop");
    var frames: u64 = 0;
    var startTime: u64 = sdl.SDL_GetPerformanceCounter();
    var currentTime: u64 = 0;
    var elapsedTime: f64 = 0;
    var fps: f64 = 0;
    while (true) {
        // calculate fps
        frames += 1;
        currentTime = sdl.SDL_GetPerformanceCounter();
        elapsedTime = @as(f64, @floatFromInt((currentTime - startTime))) / @as(f64, @floatFromInt(sdl.SDL_GetPerformanceFrequency()));
        if (elapsedTime >= 1.0) {
            fps = @as(f64, @floatFromInt(frames)) / elapsedTime;
            frames = 0;
            startTime = currentTime;
        }
        const allocator = std.heap.page_allocator;
        const newTitle: []u8 = try std.fmt.allocPrint(allocator, "WizardMirror - FPS: {d:.2}", .{fps});
        defer allocator.free(newTitle);
        const null_term_slice = try allocator.dupeZ(u8, newTitle[0..newTitle.len]);
        sdl.SDL_SetWindowTitle(window, null_term_slice);

        // handle events
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                try log.info("exiting. goodbye :)");
                return;
            }
        }

        // clear the frame
        const err = sdl.SDL_RenderClear(sdlRenderer);
        if (err != 0) {
            return _error.EngineError.SDLError;
        }

        // render our components
        try component.renderAll(initContext);
    }
}
