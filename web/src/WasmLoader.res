// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// WASM Loader for Chapel-compiled modules
// Architecture: Chapel -> emchapel -> WASM -> ReScript FFI

open Dom

// WASM module registry type
type wasmConfig = {
  wasmPath: string,
  modules: array<string>,
  timeout: int,
}

type wasmRegistry = {
  mutable modules: Dict.t<{..}>,
  mutable ready: bool,
  mutable errors: array<{module: string, error: string}>,
  config: wasmConfig,
}

// Default configuration
let defaultConfig: wasmConfig = {
  wasmPath: "/static/wasm/",
  modules: ["leetspeak", "phonetic", "pattern", "random", "markov", "hash_cracker"],
  timeout: 10000,
}

// Create global registry
let registry: wasmRegistry = {
  modules: Dict.make(),
  ready: false,
  errors: [],
  config: defaultConfig,
}

// Export to window for JS interop
let _ = %raw(`
  window.DICTI0NARY_WASM = {
    modules: {},
    ready: false,
    errors: [],
    config: {
      wasmPath: '/static/wasm/',
      modules: ['leetspeak', 'phonetic', 'pattern', 'random', 'markov', 'hash_cracker'],
      timeout: 10000
    }
  };

  // WasmModuleLoader class
  window.WasmModuleLoader = class {
    constructor(moduleName, wasmPath) {
      this.moduleName = moduleName;
      this.wasmPath = wasmPath;
      this.instance = null;
      this.memory = null;
      this.exports = null;
    }

    async load() {
      try {
        const response = await fetch(this.wasmPath + this.moduleName + '.wasm');
        if (!response.ok) {
          throw new Error('Failed to fetch ' + this.moduleName + '.wasm: ' + response.statusText);
        }

        const wasmBytes = await response.arrayBuffer();

        const importObject = {
          env: {
            memory: new WebAssembly.Memory({ initial: 256, maximum: 512 }),
            __chapel_print: (ptr, len) => {
              const str = this.readString(ptr, len);
              console.log('[Chapel] ' + str);
            },
            __chapel_error: (ptr, len) => {
              const str = this.readString(ptr, len);
              console.error('[Chapel Error] ' + str);
            },
            sin: Math.sin,
            cos: Math.cos,
            tan: Math.tan,
            exp: Math.exp,
            log: Math.log,
            pow: Math.pow,
            sqrt: Math.sqrt
          }
        };

        const wasmModule = await WebAssembly.instantiate(wasmBytes, importObject);
        this.instance = wasmModule.instance;
        this.exports = wasmModule.instance.exports;
        this.memory = importObject.env.memory;

        console.log('Loaded WASM module: ' + this.moduleName);
        return true;
      } catch (error) {
        console.error('Failed to load WASM module ' + this.moduleName + ':', error);
        window.DICTI0NARY_WASM.errors.push({ module: this.moduleName, error: error.message });
        return false;
      }
    }

    readString(ptr, len) {
      if (!this.memory) return '';
      const bytes = new Uint8Array(this.memory.buffer, ptr, len);
      return new TextDecoder('utf-8').decode(bytes);
    }

    writeString(str) {
      if (!this.memory) return { ptr: 0, len: 0 };
      const encoder = new TextEncoder();
      const bytes = encoder.encode(str);
      let ptr = this.exports.malloc ? this.exports.malloc(bytes.length) : 1024;
      const memoryBytes = new Uint8Array(this.memory.buffer, ptr, bytes.length);
      memoryBytes.set(bytes);
      return { ptr, len: bytes.length };
    }

    getFunction(name) {
      if (!this.exports || !this.exports[name]) {
        console.warn('Function ' + name + ' not found in ' + this.moduleName);
        return null;
      }
      return this.exports[name];
    }
  };

  window.getWasmModule = function(name) {
    if (!window.DICTI0NARY_WASM.ready) {
      console.warn('WASM not ready yet');
      return null;
    }
    return window.DICTI0NARY_WASM.modules[name];
  };

  window.callWasmFunction = function(moduleName, functionName, ...args) {
    const module = window.getWasmModule(moduleName);
    if (!module) throw new Error('WASM module ' + moduleName + ' not loaded');
    const func = module.getFunction(functionName);
    if (!func) throw new Error('Function ' + functionName + ' not found in ' + moduleName);
    try {
      return func(...args);
    } catch (error) {
      console.error('Error calling ' + moduleName + '.' + functionName + ':', error);
      throw error;
    }
  };
`)

// Show error banner
let showError = (message: string): unit => {
  let _ = %raw(`
    (function(msg) {
      var banner = document.getElementById('wasm-error-banner');
      if (!banner) {
        banner = document.createElement('div');
        banner.id = 'wasm-error-banner';
        banner.style.cssText = 'position: fixed; top: 0; left: 0; right: 0; ' +
          'background: linear-gradient(135deg, rgba(255, 68, 102, 0.9), rgba(255, 187, 0, 0.9)); ' +
          'color: white; padding: 1rem; text-align: center; font-weight: bold; z-index: 9999; ' +
          'box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);';
        document.body.prepend(banner);
      }
      banner.textContent = 'Warning: ' + msg;
    })
  `)(message)
  ()
}

// Initialize all WASM modules
let initializeWasm = async (): bool => {
  Console.log("Initializing WASM modules...")

  // Check for WebAssembly support
  if %raw(`typeof WebAssembly === 'undefined'`) {
    Console.error("WebAssembly is not supported in this browser")
    showError("WebAssembly not supported. Please use a modern browser.")
    false
  } else {
    let result: bool = await %raw(`
      (async function() {
        const config = window.DICTI0NARY_WASM.config;
        const loadPromises = [];

        for (const moduleName of config.modules) {
          const loader = new window.WasmModuleLoader(moduleName, config.wasmPath);
          loadPromises.push(loader.load().then(success => {
            if (success) {
              window.DICTI0NARY_WASM.modules[moduleName] = loader;
            }
            return success;
          }));
        }

        const timeoutPromise = new Promise((_, reject) =>
          setTimeout(() => reject(new Error('WASM loading timeout')), config.timeout)
        );

        try {
          const results = await Promise.race([
            Promise.all(loadPromises),
            timeoutPromise
          ]);

          const successCount = results.filter(r => r).length;
          console.log('Loaded ' + successCount + '/' + config.modules.length + ' WASM modules');

          if (successCount === 0) {
            console.error('No WASM modules loaded successfully');
            return false;
          }

          window.DICTI0NARY_WASM.ready = true;
          console.log('WASM initialization complete');
          window.dispatchEvent(new CustomEvent('wasm-ready'));
          return true;
        } catch (error) {
          console.error('WASM initialization failed:', error);
          return false;
        }
      })()
    `)

    if !result {
      showError("Failed to load WASM modules. Running in degraded mode.")
    }

    result
  }
}

// Auto-initialize when DOM is ready
let _ = if Document.readyState === "loading" {
  Document.addEventListener("DOMContentLoaded", () => {
    let _ = initializeWasm()
  })
} else {
  let _ = initializeWasm()
}

Console.log("WASM Loader initialized")
