const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

pub const GenerateOptions = struct {
    frequency: f32,
    amplitude: f32,
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};

pub fn generate(options: GenerateOptions) !Wave {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const data: []const f32 = generate_base_data(options.frequency, options.amplitude, options.length, sample_rate, options.allocator);
    defer options.allocator.free(data);

    const result: Wave = try Wave.init(data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}


fn generate_base_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    var result: []f32 = allocator.alloc(f32, length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };

    var prng = std.Random.DefaultPrng.init(0);
    const rand = prng.random();

    const period = @as(usize, @intFromFloat(sample_rate / frequency));
    var buffer: [5000]f32 = undefined;

    for (buffer[0..period]) |*val| {
        const w = rand.float(f32) * 2.0 - 1.0;
        val.* = (w + (w * 0.5)) * 0.7;
    }

    var idx: usize = 0;
    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        const next_idx = (idx + 1) % period;
        const avg = (buffer[idx] + buffer[next_idx]) * 0.5;
        const decay = 0.998;
        buffer[idx] = avg * decay;

        result[i] = std.math.tanh(avg * 1.2) * amplitude;
        idx = next_idx;
    }

    var prev: f32 = 0.0;
    const lp_factor: f32 = 0.99;
    for (result) |*val| {
        prev = prev * lp_factor + val.* * (1.0 - lp_factor);
        val.* = prev;
    }

    return result;
}

