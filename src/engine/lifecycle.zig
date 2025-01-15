const lib = @import("lib.zig");
const errors = @import("errors.zig");
const component = @import("component.zig");
const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL_ttf.h");
});

pub var sdlRenderer: ?*sdl.SDL_Renderer = null;
pub var ttfFont: ?*sdl.TTF_Font = null;

// run the engine
pub fn run(initContext: lib.InitializationContext) !void {
    sdl.SDL_Log("Welcome to WizardMirror");

    // initialize sdl
    if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to initialize SDL: %s", sdl.SDL_GetError());
    }
    defer sdl.SDL_Quit();

    // initialize ttf
    var err = sdl.TTF_Init();
    if (err != 0) {
        return errors.SDLError.TTFInitFailed;
    }
    defer sdl.TTF_Quit();
    ttfFont = sdl.TTF_OpenFont("/usr/share/fonts/google-noto/NotoSans-Regular.ttf", 16);
    if (ttfFont == null) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to initialize SDL_ttf: %s", sdl.SDL_GetError());
        return errors.SDLError.TTFInitFailed;
    }
    // create our prerequisites
    const window = sdl.SDL_CreateWindow(
        "WizardMirror",
        sdl.SDL_WINDOWPOS_CENTERED,
        sdl.SDL_WINDOWPOS_CENTERED,
        800,
        600,
        sdl.SDL_WINDOW_SHOWN,
    );
    if (window == null) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to create window: %s", sdl.SDL_GetError());
        return errors.SDLError.CreateWindowFailed;
    }
    defer sdl.SDL_DestroyWindow(window);

    sdlRenderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC);
    defer sdl.SDL_DestroyRenderer(sdlRenderer);

    sdl.SDL_RenderPresent(sdlRenderer);
    var event: sdl.SDL_Event = undefined;

    // initialize components
    try component.initializeAll(initContext);

    // enter our main loop
    sdl.SDL_Log("Blasting off...");
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
                sdl.SDL_Log("Goodbye :)");
                return;
            }
        }

        // clear our screen
        err = sdl.SDL_SetRenderDrawColor(sdlRenderer, 0, 0, 0, 255);
        if (err != 0) {
            sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to set the draw color color: %s", sdl.SDL_GetError());
            return errors.SDLError.SetRenderDrawColorFailed;
        }
        err = sdl.SDL_RenderClear(sdlRenderer);
        if (err != 0) {
            sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to clear renderer: %s", sdl.SDL_GetError());
            return errors.SDLError.RenderClearFailed;
        }

        // render the components
        try component.renderAll(initContext);
        sdl.SDL_RenderPresent(sdlRenderer);
        sdl.SDL_Delay(16);
    }
}
