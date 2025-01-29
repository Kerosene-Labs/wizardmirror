const std = @import("std");
const engine = @import("engine");
const service = @import("service");

const components = @import("components");

pub fn main() !void {
    std.log.info("welcome to wizard mirror", .{});
    std.log.info("starting pre-bootstrap process", .{});

    // initialize our config
    try service.config.init();

    // register our components
    std.log.info("beginning registration of components", .{});
    try engine.component.register(
        "news_headlines",
        &components.news_headlines.init,
        &components.news_headlines.render,
        &components.news_headlines.deinit,
    );
    std.log.info("registration of components complete", .{});

    // entrypoint
    try engine.lifecycle.run();
}
