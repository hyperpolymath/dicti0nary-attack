// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// Main application module for dicti0nary-attack web interface

open Dom

// Application state
type appState = {
  mutable currentTab: string,
  mutable wasmReady: bool,
  mutable processing: bool,
}

let state: appState = {
  currentTab: "generate",
  wasmReady: false,
  processing: false,
}

// Utility: escape HTML for XSS prevention
let escapeHtml = (text: string): string => {
  let div = Document.createElement("div")
  Element.textContent(div, text)
  %raw(`div.innerHTML`)
}

// Utility: parse int from input value
let parseInt = (s: string): int => {
  let result = %raw(`parseInt(s, 10)`)
  if %raw(`isNaN(result)`) {
    0
  } else {
    result
  }
}

// Set form loading state
let setFormLoading = (form: Element.t, loading: bool): unit => {
  let _ = %raw(`
    (function(form, loading) {
      var btn = form.querySelector('button[type="submit"]');
      if (loading) {
        form.classList.add('loading');
        if (btn) { btn.disabled = true; btn.textContent = 'Processing...'; }
      } else {
        form.classList.remove('loading');
        if (btn) { btn.disabled = false; btn.textContent = btn.getAttribute('data-original-text') || 'Submit'; }
      }
    })
  `)(form, loading)
  ()
}

// Tab navigation setup
let setupTabNavigation = (): unit => {
  let tabButtons = Document.querySelectorAll(".tab-button")
  let tabPanels = Document.querySelectorAll(".tab-panel")

  tabButtons->Array.forEach(button => {
    Element.addEventListener(button, "click", () => {
      switch button->Element.getAttribute("data-tab")->Nullable.toOption {
      | Some(tabName) => {
          // Update button states
          tabButtons->Array.forEach(btn => {
            btn->Element.classList->ignore
            let _ = %raw(`btn.classList.remove('active')`)
            btn->Element.setAttribute("aria-selected", "false")
          })
          let _ = %raw(`button.classList.add('active')`)
          button->Element.setAttribute("aria-selected", "true")

          // Update panel visibility
          tabPanels->Array.forEach(panel => {
            Element.hidden(panel, true)
          })

          switch Document.getElementById(tabName)->Nullable.toOption {
          | Some(activePanel) => {
              Element.hidden(activePanel, false)
              state.currentTab = tabName
            }
          | None => ()
          }
        }
      | None => ()
      }
    })
  })
}

// Generate form handler
let setupGenerateForm = (): unit => {
  switch Document.getElementById("generate-form")->Nullable.toOption {
  | Some(form) => {
      let outputPanel = Document.getElementById("generate-output")->Nullable.toOption

      let _ = %raw(`
        form.addEventListener('submit', async function(e) {
          e.preventDefault();

          if (!window.__RESCRIPT_APP_STATE__.wasmReady) {
            window.__RESCRIPT_NOTIFICATION__.show('WASM modules not ready yet. Please wait...', 'warning');
            return;
          }

          if (window.__RESCRIPT_APP_STATE__.processing) {
            window.__RESCRIPT_NOTIFICATION__.show('Already processing. Please wait...', 'warning');
            return;
          }

          var genType = form.querySelector('#gen-type').value;
          var count = parseInt(form.querySelector('#gen-count').value, 10);
          var minLength = parseInt(form.querySelector('#gen-min').value, 10);
          var maxLength = parseInt(form.querySelector('#gen-max').value, 10);

          if (count < 1 || count > 10000) {
            window.__RESCRIPT_NOTIFICATION__.show('Count must be between 1 and 10,000', 'error');
            return;
          }

          if (minLength > maxLength) {
            window.__RESCRIPT_NOTIFICATION__.show('Min length cannot be greater than max length', 'error');
            return;
          }

          window.__RESCRIPT_APP_STATE__.processing = true;
          window.__RESCRIPT_SET_FORM_LOADING__(form, true);

          try {
            var startTime = performance.now();
            var passwords = window.__RESCRIPT_GENERATORS__.generate(genType, count, minLength, maxLength);
            var endTime = performance.now();
            var elapsed = ((endTime - startTime) / 1000).toFixed(2);

            var outputPanel = document.getElementById('generate-output');
            var outputStats = outputPanel.querySelector('.output-stats');
            var outputContent = outputPanel.querySelector('.output-content');

            outputStats.innerHTML = '<div><strong>' + passwords.length + '</strong><span>Generated</span></div>' +
              '<div><strong>' + genType + '</strong><span>Generator</span></div>' +
              '<div><strong>' + minLength + '-' + maxLength + '</strong><span>Length Range</span></div>' +
              '<div><strong>' + elapsed + 's</strong><span>Time Taken</span></div>';

            outputContent.textContent = passwords.join('\\n');
            outputPanel.hidden = false;

            window.__RESCRIPT_NOTIFICATION__.show('Generated ' + passwords.length + ' passwords in ' + elapsed + 's', 'success');
          } catch (error) {
            console.error('Generation error:', error);
            window.__RESCRIPT_NOTIFICATION__.show('Generation failed: ' + error.message, 'error');
          } finally {
            window.__RESCRIPT_APP_STATE__.processing = false;
            window.__RESCRIPT_SET_FORM_LOADING__(form, false);
          }
        })
      `)
      ()
    }
  | None => ()
  }
}

// Hash form handler
let setupHashForm = (): unit => {
  switch Document.getElementById("hash-form")->Nullable.toOption {
  | Some(form) => {
      let _ = %raw(`
        form.addEventListener('submit', async function(e) {
          e.preventDefault();

          if (!window.__RESCRIPT_APP_STATE__.wasmReady) {
            window.__RESCRIPT_NOTIFICATION__.show('WASM modules not ready yet. Please wait...', 'warning');
            return;
          }

          var password = form.querySelector('#hash-input').value;
          var algorithm = form.querySelector('#hash-algo').value;

          if (!password) {
            window.__RESCRIPT_NOTIFICATION__.show('Please enter a password to hash', 'error');
            return;
          }

          window.__RESCRIPT_SET_FORM_LOADING__(form, true);

          try {
            var startTime = performance.now();
            var hash = await window.__RESCRIPT_HASH__.hashPassword(password, algorithm);
            var endTime = performance.now();
            var elapsed = ((endTime - startTime) * 1000).toFixed(2);

            var outputPanel = document.getElementById('hash-output');
            var outputContent = outputPanel.querySelector('.output-content');

            outputContent.textContent = 'Algorithm: ' + algorithm.toUpperCase() + '\\nHash: ' + hash + '\\n\\nTime: ' + elapsed + 'ms';
            outputPanel.hidden = false;

            window.__RESCRIPT_NOTIFICATION__.show('Password hashed using ' + algorithm.toUpperCase(), 'success');
          } catch (error) {
            console.error('Hashing error:', error);
            window.__RESCRIPT_NOTIFICATION__.show('Hashing failed: ' + error.message, 'error');
          } finally {
            window.__RESCRIPT_SET_FORM_LOADING__(form, false);
          }
        })
      `)
      ()
    }
  | None => ()
  }
}

// Crack form handler
let setupCrackForm = (): unit => {
  switch Document.getElementById("crack-form")->Nullable.toOption {
  | Some(form) => {
      let _ = %raw(`
        form.addEventListener('submit', async function(e) {
          e.preventDefault();

          if (!window.__RESCRIPT_APP_STATE__.wasmReady) {
            window.__RESCRIPT_NOTIFICATION__.show('WASM modules not ready yet. Please wait...', 'warning');
            return;
          }

          if (window.__RESCRIPT_APP_STATE__.processing) {
            window.__RESCRIPT_NOTIFICATION__.show('Already processing. Please wait...', 'warning');
            return;
          }

          var hash = form.querySelector('#crack-hash').value.trim();
          var algorithm = form.querySelector('#crack-algo').value;
          var generator = form.querySelector('#crack-gen').value;
          var maxAttempts = parseInt(form.querySelector('#crack-max').value, 10);

          if (!hash || !window.__RESCRIPT_HASH__.isValidHash(hash, algorithm)) {
            window.__RESCRIPT_NOTIFICATION__.show('Invalid ' + algorithm.toUpperCase() + ' hash format', 'error');
            return;
          }

          window.__RESCRIPT_APP_STATE__.processing = true;
          window.__RESCRIPT_SET_FORM_LOADING__(form, true);

          try {
            var startTime = performance.now();
            var result = await window.__RESCRIPT_HASH__.crackHashFallback(hash, algorithm, generator, maxAttempts);
            var endTime = performance.now();
            var elapsed = ((endTime - startTime) / 1000).toFixed(2);

            var outputPanel = document.getElementById('crack-output');
            var outputContent = outputPanel.querySelector('.output-content');

            if (result.found) {
              outputContent.innerHTML = '<div class="text-success" style="margin-bottom: 1rem;"><strong>Password Found!</strong></div>' +
                '<div style="margin-bottom: 0.5rem;"><strong>Password:</strong> <code style="color: var(--color-success);">' + result.password + '</code></div>' +
                '<div style="margin-bottom: 0.5rem;"><strong>Attempts:</strong> ' + result.attempts.toLocaleString() + ' / ' + maxAttempts.toLocaleString() + '</div>' +
                '<div style="margin-bottom: 0.5rem;"><strong>Time:</strong> ' + elapsed + 's</div>' +
                '<div><strong>Rate:</strong> ' + Math.floor(result.attempts / elapsed).toLocaleString() + ' hashes/sec</div>';
              window.__RESCRIPT_NOTIFICATION__.show('Password cracked in ' + elapsed + 's!', 'success');
            } else {
              outputContent.innerHTML = '<div class="text-warning" style="margin-bottom: 1rem;"><strong>Password Not Found</strong></div>' +
                '<div style="margin-bottom: 0.5rem;"><strong>Attempts:</strong> ' + maxAttempts.toLocaleString() + '</div>' +
                '<div style="margin-bottom: 0.5rem;"><strong>Time:</strong> ' + elapsed + 's</div>' +
                '<div><strong>Rate:</strong> ' + Math.floor(maxAttempts / elapsed).toLocaleString() + ' hashes/sec</div>' +
                '<div style="margin-top: 1rem; color: var(--color-text-muted);">Try increasing max attempts or using a different generator.</div>';
              window.__RESCRIPT_NOTIFICATION__.show('Password not found. Try different settings.', 'warning');
            }

            outputPanel.hidden = false;
          } catch (error) {
            console.error('Cracking error:', error);
            window.__RESCRIPT_NOTIFICATION__.show('Cracking failed: ' + error.message, 'error');
          } finally {
            window.__RESCRIPT_APP_STATE__.processing = false;
            window.__RESCRIPT_SET_FORM_LOADING__(form, false);
          }
        })
      `)
      ()
    }
  | None => ()
  }
}

// Copy output to clipboard
let copyOutput = (panelId: string): unit => {
  switch Document.getElementById(panelId)->Nullable.toOption {
  | Some(panel) =>
    switch panel->Element.querySelector(".output-content")->Nullable.toOption {
    | Some(content) => {
        let text: string = %raw(`content.textContent`)
        let _ = Navigator.Clipboard.writeText(text)->Js.Promise.then_(
          _ => {
            Notification.show("Copied to clipboard!", Success)
            Js.Promise.resolve()
          },
          _,
        )->Js.Promise.catch(_ => {
          Notification.show("Failed to copy to clipboard", Error)
          Js.Promise.resolve()
        }, _)
        ()
      }
    | None => ()
    }
  | None => ()
  }
}

// Enable forms after WASM loads
let enableForms = (): unit => {
  let forms = Document.querySelectorAll(".tool-form")
  forms->Array.forEach(form => {
    switch form->Element.querySelector(`button[type="submit"]`)->Nullable.toOption {
    | Some(btn) => Element.disabled(btn, false)
    | None => ()
    }
  })
}

// Initialize application
let initialize = (): unit => {
  Console.log("Initializing dicti0nary-attack application")

  // Export state and functions for JS interop
  let _ = %raw(`
    window.__RESCRIPT_APP_STATE__ = { wasmReady: false, processing: false };
    window.__RESCRIPT_SET_FORM_LOADING__ = function(form, loading) {
      var btn = form.querySelector('button[type="submit"]');
      if (loading) {
        form.classList.add('loading');
        if (btn) { btn.disabled = true; btn.textContent = 'Processing...'; }
      } else {
        form.classList.remove('loading');
        if (btn) { btn.disabled = false; btn.textContent = btn.getAttribute('data-original-text') || 'Submit'; }
      }
    };
  `)

  // Set up UI handlers
  setupTabNavigation()
  setupGenerateForm()
  setupCrackForm()
  setupHashForm()

  // Listen for WASM ready event
  Window.addEventListener("wasm-ready", () => {
    Console.log("WASM ready, enabling forms")
    state.wasmReady = true
    let _ = %raw(`window.__RESCRIPT_APP_STATE__.wasmReady = true`)
    enableForms()
  })

  // Export copy function
  let _ = %raw(`window.copyOutput = function(panelId) {
    var panel = document.getElementById(panelId);
    if (!panel) return;
    var content = panel.querySelector('.output-content');
    if (!content) return;
    navigator.clipboard.writeText(content.textContent).then(function() {
      window.__RESCRIPT_NOTIFICATION__.show('Copied to clipboard!', 'success');
    }).catch(function(err) {
      console.error('Copy failed:', err);
      window.__RESCRIPT_NOTIFICATION__.show('Failed to copy to clipboard', 'error');
    });
  }`)

  // Add CSS animations
  let style = Document.createElement("style")
  Element.textContent(
    style,
    `
    @keyframes slideIn {
      from { transform: translateX(100%); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
      from { transform: translateX(0); opacity: 1; }
      to { transform: translateX(100%); opacity: 0; }
    }
  `,
  )
  let _ = %raw(`document.head.appendChild(style)`)

  Console.log("Application initialized")
}

// Auto-initialize when DOM is ready
let _ = if Document.readyState === "loading" {
  Document.addEventListener("DOMContentLoaded", initialize)
} else {
  initialize()
}
