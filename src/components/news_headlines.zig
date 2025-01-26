const engine = @import("engine");
const std = @import("std");
const service = @import("service");

var carousel_timer: ?engine.sdl.SDL_TimerID = null;
var content = engine.state.StringStore.init("...");
const text = engine.widget.text.TextLine(&content, 0, 0);

// Internal functions
fn doCarousel() !void {
    try content.update("Pulling content");
    while (true) {
        std.time.sleep(1 * std.time.ns_per_s);
        try content.update("Test");
        const response = try engine.http.get(std.heap.page_allocator, "https://api.weather.gov");
        std.debug.print("RESPONSE: {d}\n---\n{s}", .{ response.code, response.text });
    }
}

// Lifecycle functions
pub fn init() !void {
    // setup our text
    try text.init();
    try content.callSubscribers();

    // start our initial carousel timer
    _ = try std.Thread.spawn(.{}, doCarousel, .{});

    // get our rss feeds
}

pub fn render() !void {
    try text.render();
}

pub fn deinit() !void {}
