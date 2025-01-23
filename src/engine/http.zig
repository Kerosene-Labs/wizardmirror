pub const curl = @cImport({
    @cInclude("curl/curl.h");
});
const std = @import("std");
const errors = @import("errors.zig");

const BufferContext = struct {
    initial: ?*u8 = null,
    total_size: ?usize = null,
    allocator: *std.mem.Allocator,

    pub fn copy(self: @This()) []const u8 {
        const curl_buffer: [*]const u8 = @ptrCast(self.initial.?);
        const destination = try self.allocator.alloc(u8, self.total_size - 1);
        std.mem.copy(u8, destination, curl_buffer);
        return destination;
    }
};

fn writeCallback(ptr: ?*anyopaque, size: usize, nmemb: usize, userdata: ?*BufferContext) callconv(.C) usize {
    if (ptr == null or userdata == null) return 0;
    userdata.?.total_size = size * nmemb;
    userdata.?.initial = @ptrCast(ptr.?);
    return userdata.?.total_size;
}

fn getHandle(url: []const u8, context: *BufferContext) ?*curl.CURL {
    const handle = curl.curl_easy_init();
    if (handle) |non_null_handle| {
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_URL, url.ptr);
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_WRITEFUNCTION, writeCallback);
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_WRITEDATA, context);
        _ = curl.curl_easy_setopt(non_null_handle, curl.CURLOPT_HTTP_VERSION, curl.CURL_HTTP_VERSION_NONE);
        return non_null_handle;
    } else {
        return null;
    }
}

pub fn get(url: []const u8) !void {
    var response = BufferContext{ .allocator = &std.heap.page_allocator };
    const handle = getHandle(url, &response);
    if (handle == null) {
        return errors.EngineError.CurlError;
    }
    defer curl.curl_easy_cleanup(handle.?);

    const result = curl.curl_easy_perform(handle);
    if (result != curl.CURLE_OK) {
        return errors.EngineError.HttpError;
    }
}
