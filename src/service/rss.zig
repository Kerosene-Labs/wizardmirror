const libxml = @cImport({
    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
});
const std = @import("std");
const allocator = std.heap.page_allocator;

pub const errors = error{ ParseError, NodeNotFound };

const Headline = struct {
    title: []const u8,
    subtitle: []const u8,
};

pub fn parse(text: []const u8) !void {
    const c_text = try allocator.dupeZ(u8, text);
    defer allocator.free(c_text);

    const doc = libxml.xmlReadMemory(
        c_text,
        @intCast(c_text.len),
        "noname.xml",
        null,
        0,
    );
    if (doc == null) {
        return errors.ParseError;
    }

    // get our root and channel
    const root = libxml.xmlDocGetRootElement(doc);
    if (root == null) {
        return errors.NodeNotFound;
    }
    const channel = root.*.children[0];

    var current = channel.children;
    while (current) |item_candidate| {
        current = item_candidate.*.next;
        if (std.mem.eql(u8, std.mem.span(item_candidate.*.name), "item")) {
            std.debug.print("ITEM: {s}\n", .{item_candidate.*.name});
            continue;
        }
        std.debug.print("{s}\n", .{item_candidate.*.name});
    }
}
