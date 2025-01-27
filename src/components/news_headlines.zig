const engine = @import("engine");
const std = @import("std");
const service = @import("service");

var carousel_timer: ?engine.sdl.SDL_TimerID = null;
var content = engine.state.StringStore.init("...");
const text = engine.widget.text.TextLine(&content, 10, 10);
const allocator = std.heap.page_allocator;

// Internal functions
fn doCarousel() !void {
    var feed_content = std.ArrayList([]const u8).init(allocator);
    for (service.config.get().rss_feeds) |feed| {
        std.log.info("downloading rss feed: {s}", .{feed});
        const response = try engine.http.get(allocator, feed);
        try feed_content.append(response.text);
    }
    std.log.info("rss feeds downloaded, showing headlines", .{});

    // enter our subloop for this carousel
    while (true) {
        std.time.sleep(1 * std.time.ns_per_s);
    }
}

// Lifecycle functions
pub fn init() !void {
    // set ourselves as the lock-er. we permanently own this store.

    // start our initial carousel timer
    _ = try std.Thread.spawn(.{}, doCarousel, .{});
}

pub fn render() !void {
    try text.render();
}

pub fn deinit() !void {}
