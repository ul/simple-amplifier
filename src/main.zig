const lv2 = @cImport({
    @cInclude("lv2/lv2plug.in/ns/lv2core/lv2.h");
});

const std = @import("std");
const allocator = std.heap.c_allocator;

const PortIndex = enum {
    Gain = 0,
    Input = 1,
    Output = 2,
};

const Amp = struct {
    // Port buffers
    gain: *const f32,
    input: [*]const f32,
    output: [*]f32,
};

extern fn instantiate(
    _descriptor: [*c]const lv2.LV2_Descriptor,
    _rate: f64,
    _bundle_path: [*c]const u8,
    _features: [*c]const [*c]const lv2.LV2_Feature,
) lv2.LV2_Handle {
    return @ptrCast(lv2.LV2_Handle, allocator.create(Amp) catch null);
}

extern fn connect_port(
    instance: lv2.LV2_Handle,
    port: u32,
    data: ?*c_void,
) void {
    var amp = @ptrCast(*Amp, @alignCast(@alignOf(Amp), instance));
    switch (@intToEnum(PortIndex, @intCast(u2, port))) {
        PortIndex.Gain => {
            amp.gain = @ptrCast(*const f32, @alignCast(@alignOf(f32), data));
        },
        PortIndex.Input => {
            amp.input = @ptrCast([*]const f32, @alignCast(@alignOf(f32), data));
        },
        PortIndex.Output => {
            amp.output = @ptrCast([*]f32, @alignCast(@alignOf(f32), data));
        },
    }
}

extern fn activate(_instance: lv2.LV2_Handle) void {}

extern fn run(instance: lv2.LV2_Handle, nSamples: u32) void {
    var amp = @ptrCast(*Amp, @alignCast(@alignOf(Amp), instance));
    const gain = amp.gain.*;
    const input = amp.input;
    var output = amp.output;

    const coef = if (gain > -90.0) std.math.pow(f32, 10.0, gain * 0.05) else 0.0;

    for (input[0..nSamples]) |x, i| {
        output[i] = coef * x;
    }
}

extern fn deactivate(_instance: lv2.LV2_Handle) void {}

extern fn cleanup(instance: lv2.LV2_Handle) void {
    allocator.destroy(instance);
}

extern fn extension_data(_uri: [*c]const u8) ?*c_void {
    return null;
}

const descriptor = lv2.LV2_Descriptor{
    .URI = c"http://github.com/ul/simple-amplifier",
    .instantiate = instantiate,
    .connect_port = connect_port,
    .activate = activate,
    .run = run,
    .deactivate = deactivate,
    .cleanup = cleanup,
    .extension_data = extension_data,
};

export fn lv2_descriptor(index: u32) ?*const lv2.LV2_Descriptor {
    switch (index) {
        0 => return &descriptor,
        else => return null,
    }
}
