const std = @import("std");
const engine = @import("engine");

const log = std.log.scoped(.service_config);

const ConfigError = error{ ReadFailed, HomeEnvVarNotSet };

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const Config = struct {
    fonts: struct {
        paths: struct {
            bold: []const u8,
            semibold: []const u8,
        },
    },
    components: struct {
        news_headlines: struct {
            rss_feeds: [][]const u8,
            carousel_slide_duration: u64,
        },
    },
};
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

pub fn get() Config {
    if (config == null) {
        @panic("Programming error, Config is not set");
    }
    return config.?;
}

pub fn write() !void {}

pub fn init() !void {
    // get our path, open the file
    const home = try getHome();
    const config_path = try std.fmt.allocPrint(allocator, "{s}/.config/wizardmirror/config.json", .{home});
    defer allocator.free(config_path);
    const config_file = try std.fs.openFileAbsolute(config_path, .{ .mode = std.fs.File.OpenMode.read_only });
    defer config_file.close();
    const buffer = try config_file.readToEndAlloc(allocator, std.math.maxInt(usize));

    // parse it
    const parsed = std.json.parseFromSlice(Config, allocator, buffer, .{}) catch |err| {
        std.debug.panic("failed to parse config json: {any}", .{err});
    };
    config = parsed.value;
    std.log.info("initialized config from disk", .{});
}
