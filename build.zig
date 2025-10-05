const std = @import("std");

const public_path = "lib/";
const public_headers = [_][]const u8{
    "zdict.h",
    "zstd.h",
    "zstd_errors.h",
};

const common_headers = [_][]const u8{
    "lib/common/allocations.h",
    "lib/common/bits.h",
    "lib/common/bitstream.h",
    "lib/common/compiler.h",
    "lib/common/cpu.h",
    "lib/common/debug.h",
    "lib/common/error_private.h",
    "lib/common/fse.h",
    "lib/common/huf.h",
    "lib/common/mem.h",
    "lib/common/pool.h",
    "lib/common/portability_macros.h",
    "lib/common/threading.h",
    "lib/common/xxhash.h",
    "lib/common/zstd_deps.h",
    "lib/common/zstd_internal.h",
    "lib/common/zstd_trace.h",
};
const common_sources = [_][]const u8{
    "lib/common/debug.c",
    "lib/common/entropy_common.c",
    "lib/common/error_private.c",
    "lib/common/fse_decompress.c",
    "lib/common/pool.c",
    "lib/common/threading.c",
    "lib/common/xxhash.c",
    "lib/common/zstd_common.c",
};

const compress_headers = [_][]const u8{
    "lib/compress/clevels.h",
    "lib/compress/hist.h",
    "lib/compress/zstd_compress_internal.h",
    "lib/compress/zstd_compress_literals.h",
    "lib/compress/zstd_compress_sequences.h",
    "lib/compress/zstd_compress_superblock.h",
    "lib/compress/zstd_cwksp.h",
    "lib/compress/zstd_double_fast.h",
    "lib/compress/zstd_fast.h",
    "lib/compress/zstd_lazy.h",
    "lib/compress/zstd_ldm.h",
    "lib/compress/zstd_ldm_geartab.h",
    "lib/compress/zstd_opt.h",
    "lib/compress/zstd_preSplit.h",
    "lib/compress/zstdmt_compress.h",
};
const compress_sources = [_][]const u8{
    "lib/compress/fse_compress.c",
    "lib/compress/hist.c",
    "lib/compress/huf_compress.c",
    "lib/compress/zstd_compress.c",
    "lib/compress/zstd_compress_literals.c",
    "lib/compress/zstd_compress_sequences.c",
    "lib/compress/zstd_compress_superblock.c",
    "lib/compress/zstd_double_fast.c",
    "lib/compress/zstd_fast.c",
    "lib/compress/zstd_lazy.c",
    "lib/compress/zstd_ldm.c",
    "lib/compress/zstd_opt.c",
    "lib/compress/zstd_preSplit.c",
    "lib/compress/zstdmt_compress.c",
};

const decompress_headers = [_][]const u8{
    "lib/decompress/zstd_ddict.h",
    "lib/decompress/zstd_decompress_block.h",
    "lib/decompress/zstd_decompress_internal.h",
};
const decompress_sources = [_][]const u8{
    "lib/decompress/huf_decompress.c",
    "lib/decompress/zstd_ddict.c",
    "lib/decompress/zstd_decompress.c",
    "lib/decompress/zstd_decompress_block.c",
};
const decompress_asm = [_][]const u8{
    "lib/decompress/huf_decompress_amd64.S",
};

const dictbuilder_headers = [_][]const u8{
    "lib/dictBuilder/cover.h",
    "lib/dictBuilder/divsufsort.h",
};
const dictbuilder_sources = [_][]const u8{
    "lib/dictBuilder/cover.c",
    "lib/dictBuilder/divsufsort.c",
    "lib/dictBuilder/fastcover.c",
    "lib/dictBuilder/zdict.c",
};

const legacy_headers = [_][]const u8{
    "lib/legacy/zstd_legacy.h",
    "lib/legacy/zstd_v01.h",
    "lib/legacy/zstd_v02.h",
    "lib/legacy/zstd_v03.h",
    "lib/legacy/zstd_v04.h",
    "lib/legacy/zstd_v05.h",
    "lib/legacy/zstd_v06.h",
    "lib/legacy/zstd_v07.h",
};
const legacy_sources = [_][]const u8{
    "lib/legacy/zstd_v01.c",
    "lib/legacy/zstd_v02.c",
    "lib/legacy/zstd_v03.c",
    "lib/legacy/zstd_v04.c",
    "lib/legacy/zstd_v05.c",
    "lib/legacy/zstd_v06.c",
    "lib/legacy/zstd_v07.c",
};

const flags = [_][]const u8{};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("zstd", .{});

    const mod = b.createModule(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "zstd",
        .linkage = .static,
        .root_module = mod,
    });
    lib.installHeadersDirectory(upstream.path(public_path), "", .{
        .include_extensions = &public_headers,
    });
    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = &common_sources });
    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = &compress_sources });
    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = &decompress_sources });
    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = &dictbuilder_sources });
    lib.addCSourceFiles(.{ .root = upstream.path(""), .files = &legacy_sources });

    lib.root_module.addCMacro("XXH_NAMESPACE", "ZSTD_");
    lib.root_module.addCMacro("ZSTD_MULTITHREAD", "");
    lib.root_module.addCMacro("ZSTD_BUILD_STATIC", "ON");
    lib.root_module.addCMacro("ZSTD_BUILD_SHARED", "OFF");
    lib.root_module.addCMacro("ZSTD_LEGACY_SUPPORT", "7");

    if (target.result.cpu.arch == .x86_64) {
        lib.addCSourceFiles(.{ .root = upstream.path(""), .files = &decompress_asm });
    } else {
        lib.root_module.addCMacro("ZSTD_DISABLE_ASM", "");
    }

    b.installArtifact(lib);

    // Smoke unit test
    const test_mod = b.addModule("test", .{
        .root_source_file = b.path("tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_mod.linkLibrary(lib);

    const run_mod_tests = b.addRunArtifact(b.addTest(.{ .root_module = test_mod }));

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
