const std = @import("std");
const engine = @import("engine");

const components = @import("components");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const component = try engine.component.install(components.test_polymorphism.TestPolymorphism);
    std.debug.print("{}", .{component});

    // install our components
    var installableComponents = std.ArrayList(engine.component.Component).init(allocator);
    defer installableComponents.deinit();
    // try installableComponents.append(components.test_polymorphism.TestPolymorphism);
    // try installableComponents.append(components.headlines.metadata);

    // pass them to our init context
    const initializationContext = engine.InitializationContext{
        .components = installableComponents,
    };
    try engine.lifecycle.run(initializationContext);
}
