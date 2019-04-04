# Simple Amplifier

This is a very simple example of LV2 plugin built in Zig.

## Build

```
$ zig version
0.3.0+90b6eab0
$ zig build install -Drelease-fast=true
```

On macOS you will get `libamp.dylib` in the project root directory.
On other platform it will be different, please be sure to update `manifest.ttl` to match the name.
