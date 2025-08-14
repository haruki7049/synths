//! English: Square Wave
//!
//! Japanese: 矩形波

const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

pub const GenerateOptions = struct {
    frequency: f32,
    amplitude: f32,
    sharpness: f32,
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};

pub fn generate(options: GenerateOptions) !Wave {
    const data: []const f32 = generate_data(options);
    defer options.allocator.free(data);

    const result: Wave = try Wave.init(data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}

fn generate_data(options: GenerateOptions) []const f32 {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const radins_per_sec: f32 = options.frequency * (2.0 * std.math.pi);

    var result: []f32 = options.allocator.alloc(f32, options.length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        const sine_wave = std.math.sin(@as(f32, @floatFromInt(i)) * radins_per_sec / sample_rate);
        result[i] = std.math.tanh(options.sharpness * sine_wave);
    }

    return result;
}
