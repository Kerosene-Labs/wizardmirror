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

    if (!engine.sdl.SDL_SetHint(engine.sdl.SDL_HINT_APP_ID, "WizardMirror")) {
        log.err("failed to set 'app_id': {s}", .{engine.sdl.SDL_GetError()});
        return errors.SDLError.CreateWindowFailed;
    }

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

    sdl_renderer = engine.sdl.SDL_CreateRenderer(sdl_window, null);
    if (sdl_renderer == null) {
        log.err("failed to create renderer: {s}", .{engine.sdl.SDL_GetError()});
        return errors.SDLError.Unknown;
    }
    defer engine.sdl.SDL_DestroyRenderer(sdl_renderer);

    var event = engine.sdl.SDL_Event{
        .type = 0,
    };
    if (!engine.sdl.SDL_RenderPresent(sdl_renderer)) {
        log.err("failed to render present: {s}", .{engine.sdl.SDL_GetError()});
        return errors.SDLError.RenderPresentFailed;
    }

    // initialize components
    try component.initAll();

    // enter our main loop
    log.info("entering event loop", .{});
    while (true) {
        // handle events
        while (engine.sdl.SDL_PollEvent(@ptrCast(&event))) {
            if (event.type == engine.sdl.SDL_EVENT_QUIT) {
                log.info("got kill signal, cleaning up", .{});
                try component.deinitAll();
                log.info("goodbye :)", .{});
                return;
            } else if (event.type == engine.sdl.SDL_EVENT_KEY_UP) {
                const key: engine.sdl.SDL_Keycode = event.key.key;
                if (key == engine.sdl.SDLK_EQUALS or key == engine.sdl.SDLK_PLUS or key == engine.sdl.SDLK_KP_PLUS) {
                    engine.layout.base_font_size += 1;
                } else if (key == engine.sdl.SDLK_MINUS or key == engine.sdl.SDLK_KP_MINUS) {
                    engine.layout.base_font_size -= 1;
                } else {
                    log.err("unregistered keycode: {d}", .{key});
                }
            }
        }

        // clear our screen
        if (!engine.sdl.SDL_SetRenderDrawColor(sdl_renderer, 0, 0, 0, 255)) {
            log.err("failed to set render draw color: {s}", .{engine.sdl.SDL_GetError()});
            return errors.SDLError.SetRenderDrawColorFailed;
        }
        if (!engine.sdl.SDL_RenderClear(sdl_renderer)) {
            log.err("failed to clear renderer: {s}", .{engine.sdl.SDL_GetError()});
            return errors.SDLError.RenderClearFailed;
        }

        // // render the components
        try component.renderAll();
        if (!engine.sdl.SDL_RenderPresent(sdl_renderer)) {
            log.err("failed to clear renderer: {s}", .{engine.sdl.SDL_GetError()});
            return errors.SDLError.Unknown;
        }
    }
}
