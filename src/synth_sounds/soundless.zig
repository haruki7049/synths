const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

pub const GenerateOptions = struct {
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};

pub fn generate(options: GenerateOptions) Wave {
    const data: []const f32 = generate_data(options.length, options.allocator);
    defer options.allocator.free(data);

    const result: Wave = Wave.init(data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}

fn generate_data(length: usize, allocator: std.mem.Allocator) []const f32 {
    var result: []f32 = allocator.alloc(f32, length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };

    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        result[i] = 0.0;
    }

    return result;
}
