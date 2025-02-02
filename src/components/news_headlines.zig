const engine = @import("engine");
const std = @import("std");
const service = @import("service");

const log = std.log.scoped(.component_news_headlines);

const title_color = engine.widget.text.default_color;
const description_color = engine.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 128 };
var carousel_timer: ?engine.sdl.SDL_TimerID = null;
var title = engine.state.StringStore.init("...");
var description = engine.state.StringStore.init("");

var test_store = engine.state.StringStore.init("");
const test_text = engine.widget.text.TextLine(&test_store, 1.0, engine.font.FontWeights.SEMIBOLD, title_color, 0, 1);
const title_text = engine.widget.text.TextLine(&title, 1.0, engine.font.FontWeights.BOLD, title_color, 0, 1);
const description_text = engine.widget.text.TextLine(&description, 0.8, engine.font.FontWeights.SEMIBOLD, description_color, 0, 1);
const allocator = std.heap.page_allocator;

// Internal functions
fn doCarousel() !void {
    const config = service.config.get();
    var feed_content = std.ArrayList([]const u8).init(allocator);
    for (config.news_headlines.rss_feeds) |feed| {
        log.info("downloading rss feed: {s}", .{feed});
        const response = try engine.http.get(allocator, feed);
        try feed_content.append(response.text);
    }
    log.info("{d} rss feed(s) downloaded, showing headlines", .{config.news_headlines.rss_feeds.len});

    // parse our feed content
    var headlines = std.ArrayList(service.rss.Item).init(allocator);
    for (feed_content.items) |feed| {
        const parsed_feed_items = try service.rss.parse(feed);
        for (parsed_feed_items.items) |parsed_item| {
            try headlines.append(parsed_item);
        }
    }

    // enter our subloop for this carousel
    var current_headline_index: u64 = 0;
    while (true) {
        const current_headline = headlines.items[current_headline_index];
        try title.update(current_headline.title);

        var current_headline_description: []const u8 = "";
        if (current_headline.description != null) {
            current_headline_description = current_headline.description.?;
        }
        try description.update(current_headline_description);
        std.time.sleep(4 * std.time.ns_per_s);
        current_headline_index = current_headline_index + 1;
    }
}

// Lifecycle functions
pub fn init() !void {
    // start our initial carousel timer
    const carousel_thread = try std.Thread.spawn(.{}, doCarousel, .{});
    carousel_thread.detach();
}

pub fn render() !void {
    try test_text.render();
    try title_text.render();
    try description_text.render();
}

pub fn deinit() !void {}
