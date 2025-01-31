const engine = @import("lib.zig");
const errors = @import("errors.zig");
const component = @import("component.zig");
const std = @import("std");

const log = std.log.scoped(.engine_lifecycle);

pub var sdl_renderer: ?*engine.sdl.SDL_Renderer = null;
pub var sdl_window: ?*engine.sdl.SDL_Window = null;

// run the engine
pub fn run() !void {
    log.info("bootstrapping engine", .{});

    // initialize ttf
    if (!engine.sdl.TTF_Init()) {
        return errors.SDLError.TTFInitFailed;
    }
    defer engine.sdl.TTF_Quit();

    // create our prerequisites
    sdl_window = engine.sdl.SDL_CreateWindow("WizardMirror", 600, 800, engine.sdl.SDL_WINDOW_RESIZABLE);
    if (sdl_window == null) {
        log.err("failed to open sdl window: {s}", .{engine.sdl.SDL_GetError()});
        return errors.SDLError.CreateWindowFailed;
    }
    defer engine.sdl.SDL_DestroyWindow(sdl_window);

    sdl_renderer = engine.sdl.SDL_CreateRenderer(sdl_window, "root");
    defer engine.sdl.SDL_DestroyRenderer(sdl_renderer);

    var event: ?engine.sdl.SDL_Event = null;
    if (engine.sdl.SDL_RenderPresent(sdl_renderer)) {
        log.err("failed to render present: {s}", .{engine.sdl.SDL_GetError()});
        return errors.SDLError.RenderPresentFailed;
    }

    // initialize components
    try component.initAll();

    // enter our main loop
    log.info("entering event loop", .{});
    var frames: u64 = 0;
    var startTime: u64 = engine.sdl.SDL_GetPerformanceCounter();
    var currentTime: u64 = 0;
    var elapsedTime: f64 = 0;
    var fps: f64 = 0;
    while (true) {
        // calculate fps
        frames += 1;
        currentTime = engine.sdl.SDL_GetPerformanceCounter();
        elapsedTime = @as(f64, @floatFromInt((currentTime - startTime))) / @as(f64, @floatFromInt(engine.sdl.SDL_GetPerformanceFrequency()));
        if (elapsedTime >= 1.0) {
            fps = @as(f64, @floatFromInt(frames)) / elapsedTime;
            frames = 0;
            startTime = currentTime;
        }
        const allocator = std.heap.page_allocator;
        const newTitle: []u8 = try std.fmt.allocPrint(allocator, "WizardMirror - FPS: {d:.2}", .{fps});
        const null_term_slice = try allocator.dupeZ(u8, newTitle[0..newTitle.len]);

        if (!engine.sdl.SDL_SetWindowTitle(sdl_window, null_term_slice)) {
            log.err("failed to set window title: {s}", .{engine.sdl.SDL_GetError()});
            return errors.SDLError.Unknown;
        }

        allocator.free(newTitle);
        allocator.free(null_term_slice);

        // handle events
        while (engine.sdl.SDL_PollEvent(&event.?)) {
            if (event.?.type == engine.sdl.SDL_EVENT_QUIT) {
                log.info("got kill signal, cleaning up", .{});
                try component.deinitAll();
                log.info("goodbye :)", .{});
                return;
            } else if (event.?.type == engine.sdl.SDL_KEYUP) {
                const key: engine.sdl.SDL_Keycode = event.?.key.keysym.sym;
                if (key == engine.sdl.SDLK_EQUALS or key == engine.sdl.SDLK_PLUS or key == engine.sdl.SDLK_KP_PLUS) {
                    engine.layout.base_font_size += 1;
                } else if (key == engine.sdl.SDLK_MINUS or key == engine.sdl.SDLK_KP_MINUS) {
                    engine.layout.base_font_size -= 1;
                } else {
                    log.err("unregistered keycode: {d}", .{key});
                }
            }
        }

        // calculate our root font size
        try engine.layout.scaleRootFontSize();

        // clear our screen
        if (!engine.sdl.SDL_SetRenderDrawColor(sdl_renderer, 0, 0, 0, 255)) {
            log.err("failed to set render draw color: {s}", .{engine.sdl.SDL_GetError()});
            return errors.SDLError.SetRenderDrawColorFailed;
        }
        if (!engine.sdl.SDL_RenderClear(sdl_renderer)) {
            log.err("failed to clear renderer: {s}", .{engine.sdl.SDL_GetError()});
            return errors.SDLError.RenderClearFailed;
        }

        // render the components
        try component.renderAll();
        engine.sdl.SDL_RenderPresent(sdl_renderer);
    }
}
