const std = @import("std");
const engine = @import("engine");

const components = @import("components");

const compiled_components = engine.component.compileAll(.{components.news_headlines.MainHeadline});

pub fn main() !void {
    // pass them to our init context
    try engine.lifecycle.run(compiled_components);
}
