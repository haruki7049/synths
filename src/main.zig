const std = @import("std");
const lightmix = @import("lightmix");
const synths = @import("synths");

const allocator = std.heap.page_allocator;
const Wave = lightmix.Wave;

const c_2: f32 = 65.406;
const c_3: f32 = 130.813;
const c_4: f32 = 261.626;
const c_5: f32 = 523.251;

pub fn main() !void {
    const result: Wave = synths.SynthSounds.Sine.generate(.{
        .frequency = c_4,
        .amplitude = 1.0,
        .length = 44100,
        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
        .bits = 16,
    }).filter(decay);
    defer result.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try result.write(file);
}

fn decay(original_wave: Wave) !Wave {
    var result = std.ArrayList(f32).init(original_wave.allocator);

    for (original_wave.data, 0..) |data, n| {
        const i = original_wave.data.len - n;
        const volume: f32 = @as(f32, @floatFromInt(i)) * (1.0 / @as(f32, @floatFromInt(original_wave.data.len)));

        const new_data = data * volume;
        try result.append(new_data);
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = original_wave.sample_rate,
        .channels = original_wave.channels,
        .bits = original_wave.bits,
    };
}
