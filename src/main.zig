const std = @import("std");
const engine = @import("engine");
const config = @import("service/config.zig");

const components = @import("components");

pub fn main() !void {
    engine.sdl.SDL_Log("Welcome to WizardMirror");

    // initialize our config
    try config.init();

    // register our components
    engine.sdl.SDL_Log("Beginning registration of components");
    try engine.component.register(
        "news_headlines",
        &components.news_headlines.init,
        &components.news_headlines.render,
        &components.news_headlines.deinit,
    );
    engine.sdl.SDL_Log("Registration of components complete");

    // entrypoint
    try engine.lifecycle.run();
}
