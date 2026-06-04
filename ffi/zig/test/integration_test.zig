// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// dicti0nary-attack — Zig FFI Integration Tests
//
// These tests verify the Zig FFI layer logic for the password generator/cracker.
// They run standalone without requiring the shared library, testing the FFI
// helper logic (error codes, hash detection, normalisation) independently.

const std = @import("std");
const testing = std.testing;

// ---------------------------------------------------------------------------
// FFI error codes (C ABI compatible, mirrors crates/core)
// ---------------------------------------------------------------------------

const DictError = enum(c_int) {
    ok = 0,
    io = 1,
    config = 2,
    unknown_hash = 3,
    generator = 4,
    cracker = 5,
    null_pointer = 99,
};

fn errorFromInt(code: c_int) DictError {
    return switch (code) {
        0 => .ok,
        1 => .io,
        2 => .config,
        3 => .unknown_hash,
        4 => .generator,
        5 => .cracker,
        else => .null_pointer,
    };
}

// ---------------------------------------------------------------------------
// Hash type detection (mirrors HashType::detect in crates/core)
// ---------------------------------------------------------------------------

const HashType = enum { md5, sha256, sha512, bcrypt, argon2, unknown };

fn detectHashType(hash: []const u8) HashType {
    return switch (hash.len) {
        32 => .md5,
        64 => .sha256,
        128 => .sha512,
        else => {
            if (std.mem.startsWith(u8, hash, "$2")) return .bcrypt;
            if (std.mem.startsWith(u8, hash, "$argon2")) return .argon2;
            return .unknown;
        },
    };
}

// ---------------------------------------------------------------------------
// Generator config validation (mirrors GeneratorConfig::default checks)
// ---------------------------------------------------------------------------

const GeneratorConfig = struct {
    min_length: usize,
    max_length: usize,
    count: usize,

    fn isValid(self: GeneratorConfig) bool {
        return self.min_length > 0 and
            self.max_length >= self.min_length and
            self.count > 0;
    }
};

fn defaultConfig() GeneratorConfig {
    return .{ .min_length = 6, .max_length = 16, .count = 1000 };
}

// ---------------------------------------------------------------------------
// Stop-code normalisation (upper-case + dash→underscore)
// ---------------------------------------------------------------------------

fn normaliseCode(buf: []u8, input: []const u8) usize {
    var len: usize = 0;
    for (input) |c| {
        if (len >= buf.len) break;
        buf[len] = if (c == '-') '_' else std.ascii.toUpper(c);
        len += 1;
    }
    return len;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "DictError: ok is 0" {
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(DictError.ok));
}

test "DictError: null_pointer is 99" {
    try testing.expectEqual(@as(c_int, 99), @intFromEnum(DictError.null_pointer));
}

test "DictError: round-trip from c_int" {
    try testing.expectEqual(DictError.ok, errorFromInt(0));
    try testing.expectEqual(DictError.io, errorFromInt(1));
    try testing.expectEqual(DictError.config, errorFromInt(2));
    try testing.expectEqual(DictError.unknown_hash, errorFromInt(3));
    try testing.expectEqual(DictError.generator, errorFromInt(4));
    try testing.expectEqual(DictError.cracker, errorFromInt(5));
    try testing.expectEqual(DictError.null_pointer, errorFromInt(42));
}

test "HashType: MD5 detected by length 32" {
    const hash = "d41d8cd98f00b204e9800998ecf8427e";
    try testing.expectEqual(HashType.md5, detectHashType(hash));
}

test "HashType: SHA256 detected by length 64" {
    const hash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    try testing.expectEqual(HashType.sha256, detectHashType(hash));
}

test "HashType: bcrypt detected by prefix $2" {
    const hash = "$2b$12$somehashvalue";
    try testing.expectEqual(HashType.bcrypt, detectHashType(hash));
}

test "HashType: argon2 detected by prefix $argon2" {
    const hash = "$argon2id$v=19$m=65536,t=2,p=1$somesalt$somehash";
    try testing.expectEqual(HashType.argon2, detectHashType(hash));
}

test "HashType: unknown for unrecognised input" {
    try testing.expectEqual(HashType.unknown, detectHashType("notahash"));
    try testing.expectEqual(HashType.unknown, detectHashType(""));
}

test "GeneratorConfig: default config is valid" {
    const cfg = defaultConfig();
    try testing.expect(cfg.isValid());
}

test "GeneratorConfig: min > max is invalid" {
    const cfg = GeneratorConfig{ .min_length = 10, .max_length = 5, .count = 100 };
    try testing.expect(!cfg.isValid());
}

test "GeneratorConfig: zero count is invalid" {
    const cfg = GeneratorConfig{ .min_length = 6, .max_length = 16, .count = 0 };
    try testing.expect(!cfg.isValid());
}

test "GeneratorConfig: zero min_length is invalid" {
    const cfg = GeneratorConfig{ .min_length = 0, .max_length = 16, .count = 100 };
    try testing.expect(!cfg.isValid());
}

test "normaliseCode: lowercase to uppercase" {
    var buf: [64]u8 = undefined;
    const len = normaliseCode(&buf, "coffee_not_found");
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", buf[0..len]);
}

test "normaliseCode: dashes become underscores" {
    var buf: [64]u8 = undefined;
    const len = normaliseCode(&buf, "coffee-not-found");
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", buf[0..len]);
}

test "normaliseCode: already-normalised is idempotent" {
    var buf: [64]u8 = undefined;
    const len = normaliseCode(&buf, "COFFEE_NOT_FOUND");
    try testing.expectEqualStrings("COFFEE_NOT_FOUND", buf[0..len]);
}
