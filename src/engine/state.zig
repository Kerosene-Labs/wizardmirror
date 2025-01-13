const std = @import("std");
const engine = @import("engine");
pub const StringStore = Store([]u8);

// Inspired by Svelte stores, these are handly little doo-dads that allow code to subscribe to state changes.
pub fn Store(comptime T: type) type {
    return struct {
        value: T,
        susbcriptions: std.ArrayList(*const fn () engine._error.EngineError!void),

        pub fn update(self: *Store, new: T) void {
            self.value = new;
        }

        pub fn subscribe(self: *Store, callback: *const fn () engine._error.EngineError!void) void {
            self.susbcriptions.append(callback);
        }
    };
}
