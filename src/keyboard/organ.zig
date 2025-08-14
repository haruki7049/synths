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
    const data: []const f32 = generate_organ_data(options.frequency, options.amplitude, options.length, sample_rate, options.allocator);
    defer options.allocator.free(data);

    const organ: Wave = try Wave.init(data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return organ;
}

fn generate_organ_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    var result: []f32 = allocator.alloc(f32, length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    const amp = amplitude * 0.25;

    const sine1: []const f32 = generate_sine_data(frequency, amp, length, sample_rate, allocator);
    const sine2: []const f32 = generate_sine_data(frequency * 2.0, amp * 0.6, length, sample_rate, allocator);
    const sine3: []const f32 = generate_sine_data(frequency * 3.0, amp * 0.4, length, sample_rate, allocator);
    const sine4: []const f32 = generate_sine_data(frequency * 4.0, amp * 0.8, length, sample_rate, allocator);
    const sine5: []const f32 = generate_sine_data(frequency * 5.0, amp * 0.6, length, sample_rate, allocator);
    const sine6: []const f32 = generate_sine_data(frequency * 6.0, amp * 0.75, length, sample_rate, allocator);

    defer {
        allocator.free(sine1);
        allocator.free(sine2);
        allocator.free(sine3);
        allocator.free(sine4);
        allocator.free(sine5);
        allocator.free(sine6);
    }

    for (sine1, sine2, sine3, sine4, sine5, sine6, 0..) |s1, s2, s3, s4, s5, s6, i| {
        result[i] = s1 + s2 + s3 + s4 + s5 + s6;
    }

    return result[0..];
}

fn generate_sine_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    const radins_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result: []f32 = allocator.alloc(f32, length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        result[i] = std.math.sin(@as(f32, @floatFromInt(i)) * radins_per_sec / sample_rate) * amplitude;
    }

    return result;
}
