/*
 * Bootstrap loader for dicti0nary-attack
 * Loads compiled ReScript modules
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 *
 * This is the ONLY JavaScript file that should exist.
 * All application logic is written in ReScript and compiled to .res.js files.
 */

'use strict';

// Dynamic import of compiled ReScript modules
// ReScript compiles to ES6 modules in lib/es6/
(async function() {
  try {
    // Load modules in order (dependencies first)
    await import('../../../lib/es6/web/src/Main.res.js');
    await import('../../../lib/es6/web/src/WasmLoader.res.js');
    await import('../../../lib/es6/web/src/App.res.js');
    console.log('ReScript modules loaded successfully');
  } catch (error) {
    console.warn('ReScript modules not compiled, using inline fallback:', error.message);
    // Fallback: the Main.res module includes inline JS exports
    // This handles the case where ReScript isn't compiled yet
  }
})();
