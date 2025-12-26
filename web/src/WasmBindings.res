// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// WebAssembly bindings for Chapel-compiled WASM modules

type wasmMemory
type wasmInstance
type wasmModule

module WasmModule = {
  type t = {
    moduleName: string,
    mutable instance: Nullable.t<wasmInstance>,
    mutable memory: Nullable.t<wasmMemory>,
    mutable exports: Nullable.t<{..}>,
  }

  let make = (moduleName: string): t => {
    moduleName,
    instance: Nullable.null,
    memory: Nullable.null,
    exports: Nullable.null,
  }
}

module WasmRegistry = {
  type config = {
    wasmPath: string,
    modules: array<string>,
    timeout: int,
  }

  type t = {
    mutable modules: Dict.t<WasmModule.t>,
    mutable ready: bool,
    mutable errors: array<{module: string, error: string}>,
    config: config,
  }

  let defaultConfig: config = {
    wasmPath: "/static/wasm/",
    modules: ["leetspeak", "phonetic", "pattern", "random", "markov", "hash_cracker"],
    timeout: 10000,
  }

  let make = (): t => {
    modules: Dict.make(),
    ready: false,
    errors: [],
    config: defaultConfig,
  }
}

// Global registry - set on window object for JS interop
@val @scope("window") external getWasmRegistry: unit => Nullable.t<WasmRegistry.t> = "DICTI0NARY_WASM"
@set @scope("window") external setWasmRegistry: WasmRegistry.t => unit = "DICTI0NARY_WASM"

// WebAssembly API bindings
module WebAssembly = {
  type memory
  type importObject
  type instantiateResult = {instance: wasmInstance}

  @val @scope("WebAssembly")
  external instantiate: (ArrayBuffer.t, importObject) => Js.Promise.t<instantiateResult> = "instantiate"

  @new @scope("WebAssembly")
  external makeMemory: {"initial": int, "maximum": int} => memory = "Memory"
}

// Fetch API for loading WASM
@val external fetch: string => Js.Promise.t<{..}> = "fetch"
