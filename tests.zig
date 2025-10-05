const std = @import("std");

const zstd = @cImport({
    @cInclude("zstd.h");
});

// Just a smoke test to make sure the library is linked correctly.
test {
    const version = zstd.ZSTD_versionString();

    try std.testing.expectEqualStrings("1.5.7", std.mem.span(version));
}
