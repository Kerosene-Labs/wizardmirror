const std = @import("std");
const engine = @import("engine");

const components = @import("components");

const compiled = &[_]engine.component.Component{
    engine.component.compile(components.news_headlines.MainHeadline),
};

pub fn main() !void {
    // entrypoint
    try engine.lifecycle.run(compiled);
}
