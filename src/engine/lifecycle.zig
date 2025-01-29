const engine = @import("lib.zig");
const errors = @import("errors.zig");
const component = @import("component.zig");
const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL_ttf.h");
});

pub var sdl_renderer: ?*sdl.SDL_Renderer = null;
pub var sdl_window: ?*sdl.SDL_Window = null;

// run the engine
pub fn run() !void {
    std.log.info("bootstrapping engine", .{});

    // initialize sdl
    if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
        std.log.err("failed to initialize sdl: {s}", .{sdl.SDL_GetError()});
    }
    defer sdl.SDL_Quit();
    _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "linear");

    // initialize ttf
    var err = sdl.TTF_Init();
    if (err != 0) {
        return errors.SDLError.TTFInitFailed;
    }
    defer sdl.TTF_Quit();

    // create our prerequisites
    sdl_window = sdl.SDL_CreateWindow(
        "WizardMirror",
        sdl.SDL_WINDOWPOS_CENTERED,
        sdl.SDL_WINDOWPOS_CENTERED,
        600,
        800,
        sdl.SDL_WINDOW_SHOWN | sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_ALLOW_HIGHDPI,
    );
    if (sdl_window == null) {
        std.log.err("failed to open sdl window: {s}", .{sdl.SDL_GetError()});
        return errors.SDLError.CreateWindowFailed;
    }
    defer sdl.SDL_DestroyWindow(sdl_window);

    sdl_renderer = sdl.SDL_CreateRenderer(sdl_window, -1, sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC);
    defer sdl.SDL_DestroyRenderer(sdl_renderer);

    sdl.SDL_RenderPresent(sdl_renderer);
    var event: sdl.SDL_Event = undefined;

    // initialize components
    try component.initAll();

    // enter our main loop
    std.log.info("entering event loop", .{});
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
        const null_term_slice = try allocator.dupeZ(u8, newTitle[0..newTitle.len]);
        sdl.SDL_SetWindowTitle(sdl_window, null_term_slice);
        allocator.free(newTitle);
        allocator.free(null_term_slice);

        // handle events
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                std.log.info("got kill signal, cleaning up", .{});
                try component.deinitAll();
                std.log.info("goodbye :)", .{});
                return;
            } else if (event.type == sdl.SDL_KEYUP) {
                const key: sdl.SDL_Keycode = event.key.keysym.sym;
                if (key == sdl.SDLK_EQUALS or key == sdl.SDLK_PLUS or key == sdl.SDLK_KP_PLUS) {
                    engine.layout.base_font_size += 1;
                } else if (key == sdl.SDLK_MINUS or key == sdl.SDLK_KP_MINUS) {
                    engine.layout.base_font_size -= 1;
                } else {
                    std.log.debug("unregistered keycode: {d}", .{key});
                }
            }
        }

        // calculate our root font size
        try engine.layout.scaleRootFontSize();

        // clear our screen
        err = sdl.SDL_SetRenderDrawColor(sdl_renderer, 0, 0, 0, 255);
        if (err != 0) {
            std.log.err("failed to set render draw color: {s}", .{sdl.SDL_GetError()});
            return errors.SDLError.SetRenderDrawColorFailed;
        }
        err = sdl.SDL_RenderClear(sdl_renderer);
        if (err != 0) {
            std.log.err("failed to clear renderer: {s}", .{sdl.SDL_GetError()});
            return errors.SDLError.RenderClearFailed;
        }

        // render the components
        try component.renderAll();
        sdl.SDL_RenderPresent(sdl_renderer);
    }
}
