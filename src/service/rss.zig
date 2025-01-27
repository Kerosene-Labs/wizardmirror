const libxml = @cImport({
    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
    @cInclude("libxml/xpath.h");
});
const std = @import("std");
const allocator = std.heap.page_allocator;

pub const errors = error{ ParseError, NodeNotFound, XPathContextError, XPathEvaluationError };

const Headline = struct {
    title: []const u8,
    subtitle: []const u8,
};

fn parseItem(node: [*c]libxml.xmlNode) !void {
    std.debug.print("ITEM: {s}\n", .{libxml.xmlNodeGetContent(node)});
}

fn getXpathContext(doc: [*c]libxml.xmlDoc) !libxml.xmlXPathContextPtr {
    const xpath_context = libxml.xmlXPathNewContext(doc);
    if (xpath_context == null) {
        return errors.XPathContextError;
    }
    return xpath_context;
}

pub fn parse(text: []const u8) !void {
    // convert our xml content to a c string
    const c_text = try allocator.dupeZ(u8, text);
    defer allocator.free(c_text);

    // get our document
    const doc = libxml.xmlReadMemory(
        c_text,
        @intCast(c_text.len),
        "noname.xml",
        null,
        0,
    );
    defer libxml.xmlFreeDoc(doc);
    if (doc == null) {
        return errors.ParseError;
    }

    // get our xpath context for this document
    const xpath_context = try getXpathContext(doc);
    defer libxml.xmlXPathFreeContext(xpath_context);
    const xpath_obj = libxml.xmlXPathEvalExpression("//rss/channel/item", xpath_context);
    defer libxml.xmlXPathFreeObject(xpath_obj);
    if (xpath_obj == null) {
        return errors.XPathEvaluationError;
    }

    // iterate over our items

    // get our root and channel
    // const root = libxml.xmlDocGetRootElement(doc);
    // if (root == null) {
    //     return errors.NodeNotFound;
    // }
    // const channel = root.*.children[0];

    // var current = channel.children;
    // while (current) |item_candidate| {
    //     current = item_candidate.*.next;
    //     if (std.mem.eql(u8, std.mem.span(item_candidate.*.name), "item")) {
    //         try parseItem(item_candidate);
    //         continue;
    //     }
    // }
}
