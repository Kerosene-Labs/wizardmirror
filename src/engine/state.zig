const std = @import("std");
const _error = @import("error.zig");
pub const StringStore = Store([]const u8);

// Inspired by Svelte stores, these are handly little doo-dads that allow code to subscribe to state changes.
pub fn Store(comptime T: type) type {
    return struct {
        value: T,
        susbcriptions: std.ArrayList(*const fn () _error.EngineError!void),

        pub fn update(self: *@This(), new: T) !void {
            self.value = new;
            for (self.susbcriptions.items) |subscriber| {
                try subscriber();
            }
        }

        pub fn subscribe(self: *@This(), callback: *const fn () _error.EngineError!void) _error.EngineError!void {
            self.susbcriptions.append(callback) catch {
                return _error.EngineError.StateError;
            };
        }
    };
}
