const std = @import("std");
const engine = @import("engine");

const components = @import("components");

pub fn main() !void {
    // pass them to our init context
    const initializationContext = engine.InitializationContext{
        .components = &.{engine.component.compile(components.news_headlines.MainHeadline)},
    };
    try engine.lifecycle.run(initializationContext);
}
