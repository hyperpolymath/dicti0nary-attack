// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// Hash utilities for password hashing and validation

open Dom

type algorithm =
  | MD5
  | SHA1
  | SHA256
  | SHA512

let algorithmFromString = (s: string): option<algorithm> =>
  switch s {
  | "md5" => Some(MD5)
  | "sha1" => Some(SHA1)
  | "sha256" => Some(SHA256)
  | "sha512" => Some(SHA512)
  | _ => None
  }

let algorithmToString = (a: algorithm): string =>
  switch a {
  | MD5 => "md5"
  | SHA1 => "sha1"
  | SHA256 => "sha256"
  | SHA512 => "sha512"
  }

let algorithmToWebCrypto = (a: algorithm): option<string> =>
  switch a {
  | MD5 => None // MD5 not in Web Crypto API
  | SHA1 => Some("SHA-1")
  | SHA256 => Some("SHA-256")
  | SHA512 => Some("SHA-512")
  }

let expectedLength = (a: algorithm): int =>
  switch a {
  | MD5 => 32
  | SHA1 => 40
  | SHA256 => 64
  | SHA512 => 128
  }

// Validate hash format
let isValidHash = (hash: string, algo: algorithm): bool => {
  let len = expectedLength(algo)
  String.length(hash) === len && Js.Re.test_(%re("/^[a-fA-F0-9]+$/"), hash)
}

// Web Crypto API bindings
module Crypto = {
  module Subtle = {
    @val @scope(("crypto", "subtle"))
    external digest: (string, ArrayBuffer.t) => Js.Promise.t<ArrayBuffer.t> = "digest"
  }
}

module TextEncoder = {
  type t

  @new external make: unit => t = "TextEncoder"
  @send external encode: (t, string) => Js.TypedArray2.Uint8Array.t = "encode"
}

// Convert ArrayBuffer to hex string
let bufferToHex = (buffer: ArrayBuffer.t): string => {
  let bytes = Js.TypedArray2.Uint8Array.fromBuffer(buffer)
  let result = ref("")
  for i in 0 to Js.TypedArray2.Uint8Array.length(bytes) - 1 {
    let byte = Js.TypedArray2.Uint8Array.unsafe_get(bytes, i)
    let hex = Js.Int.toStringWithRadix(byte, ~radix=16)
    result := result.contents ++ (String.length(hex) === 1 ? "0" ++ hex : hex)
  }
  result.contents
}

// Simple MD5 polyfill (NOT cryptographically secure, for demo only)
let md5Polyfill = (str: string): string => {
  let hash = ref(0)
  for i in 0 to String.length(str) - 1 {
    let code = String.charCodeAt(str, i)->Option.getOr(0.0)->Float.toInt
    hash := lor(land(lsl(hash.contents, 5) - hash.contents + code, 0xFFFFFFFF), 0)
  }
  let absHash = Math.abs(hash.contents)
  let hex = Js.Int.toStringWithRadix(absHash, ~radix=16)
  // Pad to 32 characters
  String.padStart(hex, 32, "0")
}

// Hash a password using Web Crypto API
let hashPassword = async (password: string, algo: algorithm): string => {
  switch algorithmToWebCrypto(algo) {
  | Some(algoName) => {
      let encoder = TextEncoder.make()
      let data = encoder->TextEncoder.encode(password)
      let buffer = Js.TypedArray2.Uint8Array.buffer(data)
      let hashBuffer = await Crypto.Subtle.digest(algoName, buffer)
      bufferToHex(hashBuffer)
    }
  | None =>
    // MD5 fallback
    md5Polyfill(password)
  }
}

type crackResult = {
  found: bool,
  password: option<string>,
  attempts: int,
}

// Crack hash using fallback generator
let crackHashFallback = async (
  targetHash: string,
  algo: algorithm,
  genType: Generators.generatorType,
  maxAttempts: int,
): crackResult => {
  let attempts = ref(0)

  while attempts.contents < maxAttempts {
    let password = Generators.generate(genType, 1, 6, 16)->Array.getUnsafe(0)
    attempts := attempts.contents + 1

    let hash = await hashPassword(password, algo)

    if String.toLowerCase(hash) === String.toLowerCase(targetHash) {
      return {found: true, password: Some(password), attempts: attempts.contents}
    }

    // Yield to UI every 1000 attempts
    if mod(attempts.contents, 1000) === 0 {
      await Js.Promise.resolve()
    }
  }

  {found: false, password: None, attempts: attempts.contents}
}
