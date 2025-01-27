const libxml = @cImport({
    @cInclude("libxml/parser.h");
    @cInclude("libxml/tree.h");
    @cInclude("libxml/xpath.h");
});
const std = @import("std");
const allocator = std.heap.page_allocator;

pub const errors = error{ ParseError, NodeNotFound, XPathContextError, XPathEvaluationError };

/// Represents an RSS `<item>`.
pub const Item = struct {
    title: []const u8,
    description: ?[]const u8,
};

/// A simple pair between a libxml2 `xmlXPathObject` and a reference to its nodes.
const EvaluatedXPath = struct {
    xpath_object: [*c]libxml.xmlXPathObject,
    nodes: [][*c]libxml.xmlNode,

    pub fn init(xpath_object: [*c]libxml.xmlXPathObject) !@This() {
        const c_nodes = xpath_object.*.nodesetval;
        const nodes = c_nodes.*.nodeTab[0..@intCast(c_nodes.*.nodeNr)];
        return EvaluatedXPath{
            .xpath_object = xpath_object,
            .nodes = nodes,
        };
    }

    pub fn deinit(self: @This()) void {
        libxml.xmlXPathFreeObject(self.xpath_object);
    }
};

fn parseItem(node: [*c]libxml.xmlNode) !Item {
    var title: []const u8 = "";
    var description: ?[]const u8 = null;

    // iterate over each child node within our item node, find the ones we need
    var current: [*c]libxml.xmlNode = @ptrCast(node.*.children);
    while (current) |child| {
        current = current.*.next;
        const name = std.mem.span(child.*.name);
        if (std.mem.eql(u8, name, "title")) {
            title = std.mem.span(libxml.xmlNodeGetContent(child));
        } else if (std.mem.eql(u8, name, "description")) {
            description = std.mem.span(libxml.xmlNodeGetContent(child));
        }
    }
    return Item{ .title = title, .description = description };
}

/// Helper to generate an `xmlPathContext` object, or return a Zig error
fn getXpathContext(doc: [*c]libxml.xmlDoc) !libxml.xmlXPathContextPtr {
    const xpath_context = libxml.xmlXPathNewContext(doc);
    if (xpath_context == null) {
        return errors.XPathContextError;
    }
    return xpath_context;
}

/// Evaluate an XPath expression, getting an `EvaluatedXPath` instance back.
fn evaluateXpath(xpath: []const u8, context: [*c]libxml.xmlXPathContext) !EvaluatedXPath {
    const c_xpath = try allocator.dupeZ(u8, xpath);
    defer allocator.free(c_xpath);
    const obj = libxml.xmlXPathEvalExpression(c_xpath, context);
    if (obj == null) {
        return errors.XPathEvaluationError;
    }
    return EvaluatedXPath.init(obj);
}

/// Parse the given XML text into a set of RSS Items
pub fn parse(text: []const u8) !std.ArrayList(Item) {
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
    const items = try evaluateXpath("//rss/channel/item", xpath_context);
    defer items.deinit();

    // iterate over our items
    var parsed_items = std.ArrayList(Item).init(allocator);
    for (items.nodes) |node| {
        try parsed_items.append(try parseItem(node));
    }
    return parsed_items;
}
