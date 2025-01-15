const std = @import("std");
const engine = @import("engine");

const components = @import("components");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // install our components
    var installableComponents = std.ArrayList(engine.component.Component).init(allocator);
    try installableComponents.append(try engine.component.compile(components.news_headlines.MainHeadline));
    defer installableComponents.deinit();

    // pass them to our init context
    const initializationContext = engine.InitializationContext{
        .components = installableComponents,
    };
    try engine.lifecycle.run(initializationContext);
}
