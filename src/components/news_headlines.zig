const tetrahedron = @import("tetrahedron");
const std = @import("std");
const service = @import("service");

const log = std.log.scoped(.component_news_headlines);

const title_color = tetrahedron.widget.text.default_color;
const description_color = tetrahedron.sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 128 };
var carousel_timer: ?tetrahedron.sdl.SDL_TimerID = null;
var title = tetrahedron.state.StringStore.init("...");
var description = tetrahedron.state.StringStore.init("");

const title_text = tetrahedron.widget.text.TextLine(&title, 1.0, tetrahedron.font.FontWeights.BOLD, title_color, 0, 1);
const description_text = tetrahedron.widget.text.TextLine(&description, 0.8, tetrahedron.font.FontWeights.SEMIBOLD, description_color, 0, 1);
const allocator = std.heap.page_allocator;

// Internal functions
fn doCarousel() !void {
    const config = service.config.get();
    var feed_content = std.ArrayList([]const u8).init(allocator);
    for (config.components.news_headlines.rss_feeds) |feed| {
        log.info("downloading rss feed: {s}", .{feed});
        const response = try tetrahedron.http.get(allocator, feed);
        try feed_content.append(response.text);
    }
    log.info("{d} rss feed(s) downloaded, showing headlines", .{config.components.news_headlines.rss_feeds.len});

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
    const text = "No render";
    const font = tetrahedron.sdl.TTF_OpenFont("/usr/share/fonts/truetype/open-sans/OpenSans-Bold.ttf", 16);
    if (font == null) {
        std.log.err("failed to render text: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return tetrahedron.errors.SDLError.Unknown;
    }
    const surface = tetrahedron.sdl.TTF_RenderText_Solid(font, text, text.len, tetrahedron.widget.text.default_color);
    if (surface == null) {
        std.log.err("failed to render text: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return tetrahedron.errors.SDLError.RenderTextFailed;
    }

    const texture = tetrahedron.sdl.SDL_CreateTextureFromSurface(tetrahedron.lifecycle.sdl_renderer, surface);
    if (texture == null) {
        std.log.err("failed to render text: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return tetrahedron.errors.SDLError.CreateTextureFromSurfaceFailed;
    }

    const rect = tetrahedron.sdl.SDL_Rect{
        .x = 0,
        .y = 0,
        .w = surface.*.w,
        .h = surface.*.h,
    };

    if (!tetrahedron.sdl.SDL_RenderTexture(tetrahedron.lifecycle.sdl_renderer, texture, null, @ptrCast(&rect))) {
        std.log.err("failed to render text: {s}", .{tetrahedron.sdl.SDL_GetError()});
        return tetrahedron.errors.SDLError.Unknown;
    }
    // try title_text.render();
    // try description_text.render();
}

pub fn deinit() !void {}
