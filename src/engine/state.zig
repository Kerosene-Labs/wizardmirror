const std = @import("std");
const errors = @import("errors.zig");
const allocator = std.heap.page_allocator;

// pre-mades
pub const StringStore = Store([]const u8);
pub const BoolStore = Store(bool);
pub const U32Store = Store(u32);

// Inspired by Svelte stores, these are handy little doo-dads that allow code to subscribe to state changes.
// Use the `init()` method to setup this struct.
pub fn Store(comptime T: type) type {
    return struct {
        value: T,
        subscriptions: std.ArrayList(*const fn () anyerror!void),

        // Initialize a new store with a `val` of `T`, and an initial subscriber. This initial subscriber will be called after creation.
        // Due to language
        pub fn init(val: T) !@This() {
            var new = @This(){
                .value = val,
                .subscriptions = std.ArrayList(*const fn () anyerror!void).init(allocator),
            };
            try new.callSubscribers();
            return new;
        }

        // Call all the subscribers
        pub fn callSubscribers(self: *@This()) !void {
            for (self.subscriptions.items) |subscriber| {
                try subscriber();
            }
        }

        // Set the value of this store. After setting, we'll call the subscribers to let them know their subscribed value has changed.
        pub fn update(self: *@This(), new: T) !void {
            self.value = new;
            try callSubscribers(self);
        }

        // Get a callback when this store's value changes. Calls the callback immediately.
        pub fn subscribe(self: *@This(), callback: *const fn () anyerror!void) anyerror!void {
            try callback();
            try self.subscriptions.append(callback);
        }
    };
}
