const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

const GenerateOptions = struct {
    allocator: std.mem.Allocator,
    volume: f32,
    length: usize,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};

pub fn generate(options: GenerateOptions) !Wave {
    const data: []f32 = generate_data(options);
    defer options.allocator.free(data);

    const result: Wave = try Wave.init(data[0..], options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    return result;
}

fn generate_data(options: GenerateOptions) []f32 {
    const sample_rate_f: f32 = @floatFromInt(options.sample_rate);
    const base_freq: f32 = 30.0; // 最終の低い周波数
    const start_freq: f32 = 60.0; // アタック時の周波数

    var result: []f32 = options.allocator.alloc(f32, options.length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };

    var i: usize = 0;
    while (i < options.length) : (i += 1) {
        const t = @as(f32, @floatFromInt(i)) / sample_rate_f;

        // ピッチが指数的に落ちる
        const freq = start_freq * std.math.pow(f32, base_freq / start_freq, t);
        const phase = 2.0 * std.math.pi * freq * t;

        // 振幅減衰（指数関数）
        const amp = std.math.exp(-t * 8.0);

        // サイン波本体
        result[i] = std.math.sin(phase) * amp * options.volume * 2.0;
    }

    return result;
}
