const engine = @import("lib.zig");
const errors = @import("errors.zig");
const component = @import("component.zig");
const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL_ttf.h");
});

pub var scaling_factor = engine.state.I32Store.init(1);
pub var sdl_renderer: ?*sdl.SDL_Renderer = null;
pub var ttf_font: ?*sdl.TTF_Font = null;

var font_cache = std.AutoHashMap(c_int, *sdl.TTF_Font).init(std.heap.page_allocator);

pub fn getFont(requested_scaling_factor: c_int) *sdl.TTF_Font {
    var cached = font_cache.get(requested_scaling_factor);
    if (cached == null) {
        cached = sdl.TTF_OpenFont("/usr/share/fonts/open-sans/OpenSans-Bold.ttf", @intCast(16 * requested_scaling_factor));
        if (cached == null) {
            sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to initialize SDL_ttf: %s", sdl.SDL_GetError());
            @panic("Failed to load font");
        }
        font_cache.put(requested_scaling_factor, cached.?) catch {
            @panic("Failed to cache font");
        };
    }
    return cached.?;
}

// run the engine
pub fn run() !void {
    // initialize sdl
    if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to initialize SDL: %s", sdl.SDL_GetError());
    }
    defer sdl.SDL_Quit();
    _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "linear");

    // initialize ttf
    var err = sdl.TTF_Init();
    if (err != 0) {
        return errors.SDLError.TTFInitFailed;
    }
    defer sdl.TTF_Quit();
    sdl.TTF_SetFontHinting(ttf_font, sdl.TTF_HINTING_NORMAL);

    // create our prerequisites
    const window = sdl.SDL_CreateWindow(
        "WizardMirror",
        sdl.SDL_WINDOWPOS_CENTERED,
        sdl.SDL_WINDOWPOS_CENTERED,
        600,
        800,
        sdl.SDL_WINDOW_SHOWN | sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_ALLOW_HIGHDPI,
    );
    if (window == null) {
        sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to create window: %s", sdl.SDL_GetError());
        return errors.SDLError.CreateWindowFailed;
    }
    defer sdl.SDL_DestroyWindow(window);

    sdl_renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC);
    defer sdl.SDL_DestroyRenderer(sdl_renderer);

    sdl.SDL_RenderPresent(sdl_renderer);
    var event: sdl.SDL_Event = undefined;

    // initialize components
    try component.initAll();

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
        allocator.free(null_term_slice);

        // handle events
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                sdl.SDL_Log("Got kill signal, cleaning up");
                try component.deinitAll();
                sdl.SDL_Log("Goodbye :)");
                return;
            }
        }

        // calculate our scaling factor
        var width: c_int = 0;
        var height: c_int = 0;
        sdl.SDL_GetWindowSizeInPixels(window, &width, &height);
        if (width >= 400 and width <= 799) {
            try scaling_factor.update(2);
        } else if (width >= 800) {
            try scaling_factor.update(3);
        }

        // get our cached font
        ttf_font = getFont(@intCast(scaling_factor.get()));

        // clear our screen
        err = sdl.SDL_SetRenderDrawColor(sdl_renderer, 0, 0, 0, 255);
        if (err != 0) {
            sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to set the draw color color: %s", sdl.SDL_GetError());
            return errors.SDLError.SetRenderDrawColorFailed;
        }
        err = sdl.SDL_RenderClear(sdl_renderer);
        if (err != 0) {
            sdl.SDL_LogError(sdl.SDL_LOG_CATEGORY_APPLICATION, "Failed to clear renderer: %s", sdl.SDL_GetError());
            return errors.SDLError.RenderClearFailed;
        }

        // render the components
        try component.renderAll();
        sdl.SDL_RenderPresent(sdl_renderer);
    }
}
