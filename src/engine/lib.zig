pub const log = @import("log.zig");
pub const _error = @import("error.zig");
pub const component = @import("component.zig");

const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

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

    const renderer = sdl.SDL_CreateRenderer(window, -1, 0);
    defer sdl.SDL_DestroyRenderer(renderer);

    var err = sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    if (err != 0) {
        try log.info("failed to render draw color");
        return _error.EngineError.SDLError;
    }

    err = sdl.SDL_RenderClear(renderer);
    if (err != 0) {
        try log.info("failed to clear renderer");
        return _error.EngineError.SDLError;
    }

    sdl.SDL_RenderPresent(renderer);
    var event: sdl.SDL_Event = undefined;
    while (true) {
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                try log.info("exiting. goodbye :)");
                return;
            }
        }
        try component.renderComponents(initContext);
        sdl.SDL_Delay(16);
    }
}
