const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

const GenerateOptions = struct {
    allocator: std.mem.Allocator,
    volume: f32,

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
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const total_samples: usize = 33075;
    const base_freq: f32 = 30.0; // 最終の低い周波数
    const start_freq: f32 = 60.0; // アタック時の周波数

    var result: []f32 = options.allocator.alloc(f32, 44100) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };

    var i: usize = 0;
    while (i < total_samples) : (i += 1) {
        const t = @as(f32, @floatFromInt(i)) / sample_rate;

        // ピッチが指数的に落ちる
        const freq = start_freq * std.math.pow(f32, base_freq / start_freq, t);
        const phase = 2.0 * std.math.pi * freq * t;

        // 振幅減衰（指数関数）
        const amp = std.math.exp(-t * 8.0);

        // サイン波本体
        result[i] = std.math.sin(phase) * amp * options.volume * 2.0;
    }

    // 残りはゼロで埋める（全体配列長は44100固定のため）
    while (i < result.len) : (i += 1) {
        result[i] = 0.0;
    }

    return result;
}
