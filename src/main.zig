const std = @import("std");
const engine = @import("engine");

const components = @import("components");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // install our components
    var installableComponents = std.ArrayList(engine.component.Component).init(allocator);
    defer installableComponents.deinit();
    try installableComponents.append(components.welcome.component);

    // pass them to our init context
    const initializationContext = engine.InitializationContext{
        .components = installableComponents,
    };
    try engine.run(initializationContext);
}
