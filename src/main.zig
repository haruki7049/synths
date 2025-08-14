const std = @import("std");
const lightmix = @import("lightmix");
const tones = @import("tones");

const allocator = std.heap.page_allocator;
const Wave = lightmix.Wave;

const c_2: f32 = 65.406;
const c_3: f32 = 130.813;
const c_4: f32 = 261.626;
const c_5: f32 = 523.251;

pub fn main() !void {
    const result: Wave = try tones.SynthSounds.Square.generate(.{
        .frequency = c_3,
        .amplitude = 1.0,
        .length = 44100,
        .sharpness = 5.0,
        .allocator = allocator,

        .sample_rate = 44100,
        .channels = 1,
        .bits = 16,
    });
    defer result.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try result.write(file);
}
