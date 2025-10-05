# [zstd](https://facebook.github.io/zstd/)@v1.5.7 [![Build and test library](https://github.com/zig-devel/zstd/actions/workflows/library.yml/badge.svg)](https://github.com/zig-devel/zstd/actions/workflows/library.yml)

Zstandard - Fast real-time compression algorithm

## Usage

Install library:

```sh
zig fetch --save https://github.com/zig-devel/zstd/archive/refs/tags/1.5.7-0.tar.gz
```

Statically link with `mod` module:

```zig
const zstd = b.dependency("zstd", .{
    .target = target,
    .optimize = optimize,
});

mod.linkLibrary(zstd.artifact("zstd"));
```

## License

All code in this repo is multi-licensed under
[0BSD](./LICENSES/0BSD.txt) OR
[BSD-3-Clause](./LICENSES/BSD-3-Clause.txt) OR
[GPL-2.0-only](./LICENSES/GPL-2.0-only.txt).
