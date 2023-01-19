const std = @import("std");

const Options = @import("../../../build.zig").Options;


inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const exe = b.addExecutable("shaders", thisDir() ++ "/main.zig");

    exe.setBuildMode(options.build_mode);
    exe.setTarget(options.target);

    return exe;

}