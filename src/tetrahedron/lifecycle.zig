const tetrahedron = @import("root.zig");
const errors = @import("errors.zig");
const component = @import("component.zig");
const std = @import("std");

const log = std.log.scoped(.engine_lifecycle);

pub var sdl_renderer: ?*tetrahedron.sdl.SDL_Renderer = null;
pub var sdl_window: ?*tetrahedron.sdl.SDL_Window = null;

// run the tetrahedron
pub fn run() !void {
    log.info("bootstrapping tetrahedron", .{});

    if (!tetrahedron.sdl.SDL_SetHint(tetrahedron.sdl.SDL_HINT_APP_ID, "WizardMirror")) {
        log.err("failed to set 'app_id': {s}", .{tetrahedron.sdl.SDL_GetError()});
        return errors.SDLError.CreateWindowFailed;
    }

    // initialize ttf
    if (!tetrahedron.sdl.TTF_Init()) {
        return errors.SDLError.TTFInitFailed;
    }
    defer tetrahedron.sdl.TTF_Quit();

    // create our prerequisites
    sdl_window = tetrahedron.sdl.SDL_CreateWindow("WizardMirror", 600, 800, tetrahedron.sdl.SDL_WINDOW_RESIZABLE);
    if (sdl_window == null) {
        log.err("failed to open sdl window: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return errors.SDLError.CreateWindowFailed;
    }
    defer tetrahedron.sdl.SDL_DestroyWindow(sdl_window);

    sdl_renderer = tetrahedron.sdl.SDL_CreateRenderer(sdl_window, null);
    if (sdl_renderer == null) {
        log.err("failed to create renderer: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return errors.SDLError.Unknown;
    }
    defer tetrahedron.sdl.SDL_DestroyRenderer(sdl_renderer);

    var event = tetrahedron.sdl.SDL_Event{
        .type = 0,
    };
    if (!tetrahedron.sdl.SDL_RenderPresent(sdl_renderer)) {
        log.err("failed to render present: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return errors.SDLError.RenderPresentFailed;
    }

    // initialize components
    try component.initAll();

    // enter our main loop
    log.info("entering event loop", .{});
    while (true) {
        // handle events
        while (tetrahedron.sdl.SDL_PollEvent(@ptrCast(&event))) {
            if (event.type == tetrahedron.sdl.SDL_EVENT_QUIT) {
                log.info("got kill signal, cleaning up", .{});
                try component.deinitAll();
                log.info("goodbye :)", .{});
                return;
            } else if (event.type == tetrahedron.sdl.SDL_EVENT_KEY_UP) {
                const key: tetrahedron.sdl.SDL_Keycode = event.key.key;
                if (key == tetrahedron.sdl.SDLK_EQUALS or key == tetrahedron.sdl.SDLK_PLUS or key == tetrahedron.sdl.SDLK_KP_PLUS) {
                    tetrahedron.layout.base_font_size += 1;
                } else if (key == tetrahedron.sdl.SDLK_MINUS or key == tetrahedron.sdl.SDLK_KP_MINUS) {
                    tetrahedron.layout.base_font_size -= 1;
                } else {
                    log.err("unregistered keycode: {d}", .{key});
                }
            }
        }

        // clear our screen
        if (!tetrahedron.sdl.SDL_SetRenderDrawColor(sdl_renderer, 0, 0, 0, 255)) {
            log.err("failed to set render draw color: {s}", .{tetrahedron.sdl.SDL_GetError()});
            return errors.SDLError.SetRenderDrawColorFailed;
        }
        if (!tetrahedron.sdl.SDL_RenderClear(sdl_renderer)) {
            log.err("failed to clear renderer: {s}", .{tetrahedron.sdl.SDL_GetError()});
            return errors.SDLError.RenderClearFailed;
        }

        // // render the components
        try component.renderAll();
        if (!tetrahedron.sdl.SDL_RenderPresent(sdl_renderer)) {
            log.err("failed to clear renderer: {s}", .{tetrahedron.sdl.SDL_GetError()});
            return errors.SDLError.Unknown;
        }
    }
}
