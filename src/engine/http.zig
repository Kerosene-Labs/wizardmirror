pub const curl = @cImport({
    @cInclude("curl/curl.h");
});
const std = @import("std");
const errors = @import("errors.zig");
const engine = @import("lib.zig");

/// Python `requests` inspired response object
const Response = struct {
    allocator: std.mem.Allocator,
    code: i64,
    headers: std.StringHashMap([]const u8),
    buffer: std.ArrayList([]const u8),
    text: []const u8,

    pub fn init(allocator: std.mem.Allocator) !@This() {
        return Response{
            .allocator = allocator,
            .code = 0,
            .headers = std.StringHashMap([]const u8).init(allocator),
            .buffer = std.ArrayList([]const u8).init(allocator),
            .text = &.{},
        };
    }
};

fn writeCallback(ptr: ?*anyopaque, size: usize, nmemb: usize, userdata: ?*Response) callconv(.C) usize {
    if (ptr == null or userdata == null) return 0;

    // if we're getting our data for the first time, initialize our destination buffer
    const curl_buffer: [*]const u8 = @ptrCast(ptr.?);
    const total_size = size * nmemb;
    const destination = userdata.?.allocator.alloc(u8, total_size) catch {
        return 0;
    };
    std.mem.copyForwards(u8, destination, curl_buffer[0..total_size]);
    userdata.?.buffer.append(destination) catch {
        return 0;
    };
    return total_size;
}

fn getHandle(url: []const u8, response: *Response) ?*curl.CURL {
    const handle = curl.curl_easy_init();
    if (handle) |non_null_handle| {
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_URL, url.ptr);
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_WRITEFUNCTION, writeCallback);
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_WRITEDATA, response);
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_HTTP_VERSION, curl.CURL_HTTP_VERSION_NONE);
        return non_null_handle;
    } else {
        return null;
    }
}

/// Send a `GET` request. Get an `http.Response` back.
pub fn get(allocator: std.mem.Allocator, url: []const u8) !Response {
    // initialize our empty response
    var response = try Response.init(allocator);

    // make our url a c string
    const c_url = try allocator.dupeZ(u8, url);
    defer allocator.free(c_url);

    // get our handle
    const handle = getHandle(c_url, &response);
    if (handle == null) {
        return errors.EngineError.CurlError;
    }
    defer curl.curl_easy_cleanup(handle.?);

    // handle our curl easy curl_code
    var curl_code = curl.curl_easy_perform(handle);
    if (curl_code != curl.CURLE_OK) {
        std.log.err("net request failed: {s}", .{curl.curl_easy_strerror(curl_code)});
        return errors.EngineError.HttpError;
    }

    curl_code = curl.curl_easy_getinfo(handle, curl.CURLINFO_RESPONSE_CODE, &response.code);
    if (curl_code != curl.CURLE_OK) {
        std.log.err("net request failed: {s}", .{curl.curl_easy_strerror(curl_code)});
        return errors.EngineError.HttpError;
    }

    // calculate our buffer size
    var total_size: u64 = 0;
    for (response.buffer.items) |chunk| {
        total_size += chunk.len;
    }

    const text_buffer = try allocator.alloc(u8, total_size);
    var current_pos: u64 = 0;
    for (response.buffer.items) |chunk| {
        std.mem.copyForwards(u8, text_buffer[current_pos..][0..chunk.len], chunk);
        current_pos += chunk.len;
    }

    response.text = text_buffer;
    return response;
}
