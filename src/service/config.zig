const std = @import("std");
const engine = @import("engine");

const ConfigError = error{ ReadFailed, HomeEnvVarNotSet };

pub const Config = struct { rss_feeds: []const u8 };
var config: ?Config = null;

// Get our home directory
fn getHome() ![]const u8 {
    const home = std.c.getenv("HOME");
    if (home) |nonNullHome| {
        return std.mem.span(nonNullHome);
    } else {
        return ConfigError.HomeEnvVarNotSet;
    }
}

pub fn write() !void {}

pub fn init() !void {
    // open our file
    const home = try getHome();
    const config_path = try std.fmt.allocPrint(std.heap.page_allocator, "{s}/.config/wizardmirror/config.json", .{home});
    const config_file = try std.fs.openFileAbsolute(config_path, .{ .mode = std.fs.File.OpenMode.read_only });

    // read the file
    const buff = &[_]u8{};
    _ = try config_file.readAll(buff);

    // parse it
    config = (try std.json.parseFromSlice(Config, std.heap.page_allocator, buff, .{})).value;
    engine.sdl.SDL_Log("Initialized config from disk");
}
