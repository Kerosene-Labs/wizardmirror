const engine = @import("engine");
pub const TestPolymorphism = struct {
    pub fn init() !void {
        engine.sdl.SDL_Log("Test polymorphic component initialized!");
    }

    pub fn render() !void {
        engine.sdl.SDL_Log("Test polymorphic component rendered!");
    }

    pub fn deinit() !void {
        engine.sdl.SDL_Log("Test polymorphic component de-initialized!");
    }
};
