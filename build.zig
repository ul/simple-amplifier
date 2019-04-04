const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addSharedLibrary("amp", "src/main.zig", b.version(0, 0, 1));
    lib.setBuildMode(mode);
    lib.setOutputDir(".");
    lib.setDisableGenH(true);

    var main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    b.default_step.dependOn(&lib.step);
    b.installArtifact(lib);
}
