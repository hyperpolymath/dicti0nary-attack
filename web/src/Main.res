// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// Main entry point - exports all modules for JS interop

// Export modules to window for JS interop
let _ = %raw(`
  // Export Notification module
  window.__RESCRIPT_NOTIFICATION__ = {
    show: function(message, type) {
      var colors = {
        success: 'var(--color-success)',
        error: 'var(--color-error)',
        warning: 'var(--color-warning)',
        info: 'var(--color-info)'
      };
      var color = colors[type] || colors.info;

      var notification = document.createElement('div');
      notification.textContent = message;
      notification.style.cssText = 'position: fixed; bottom: 2rem; right: 2rem; background: ' + color +
        '; color: var(--color-bg-primary); padding: 1rem 1.5rem; border-radius: 8px;' +
        ' box-shadow: var(--shadow-lg); font-weight: 600; z-index: 10000;' +
        ' animation: slideIn 0.3s ease;';

      document.body.appendChild(notification);

      setTimeout(function() {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(function() { notification.remove(); }, 300);
      }, 3000);
    }
  };

  // Export Generators module
  window.__RESCRIPT_GENERATORS__ = {
    generate: function(genType, count, minLen, maxLen) {
      var leetMap = { 'a': '4', 'e': '3', 'i': '1', 'o': '0', 's': '5', 't': '7' };
      var words = ['password', 'admin', 'login', 'secure', 'access', 'system'];
      var phonetic = ['for', 'to', 'you', 'see', 'why', 'are', 'bee', 'sea'];
      var phoneticNums = ['4', '2', 'u', 'c', 'y', 'r', 'b', 'c'];
      var patterns = ['qwerty', 'asdfgh', 'zxcvbn', '123456', 'qazwsx', 'qwertyuiop', 'asdfghjkl', '1qaz2wsx'];
      var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      var bigrams = ['th', 'he', 'in', 'er', 'an', 're', 'on', 'at', 'en', 'ed'];

      function randomInt(max) { return Math.floor(Math.random() * max); }

      function generateLeetspeak() {
        var word = words[randomInt(words.length)];
        var result = word.split('').map(function(c) {
          return Math.random() > 0.5 && leetMap[c] ? leetMap[c] : c;
        }).join('');
        while (result.length < minLen) result += randomInt(10);
        return result.substring(0, maxLen);
      }

      function generatePhonetic() {
        var result = '';
        var iterations = Math.ceil(maxLen / 3);
        for (var i = 0; i < iterations && result.length < maxLen; i++) {
          var idx = randomInt(phonetic.length);
          result += Math.random() > 0.5 ? phonetic[idx] : phoneticNums[idx];
        }
        return result.substring(0, Math.max(minLen, Math.min(result.length, maxLen)));
      }

      function generatePattern() {
        var result = patterns[randomInt(patterns.length)];
        if (Math.random() > 0.5) result = result.split('').reverse().join('');
        result += randomInt(1000);
        return result.substring(0, Math.max(minLen, Math.min(result.length, maxLen)));
      }

      function generateRandom() {
        var length = minLen + randomInt(maxLen - minLen + 1);
        var result = '';
        for (var i = 0; i < length; i++) result += chars.charAt(randomInt(chars.length));
        return result;
      }

      function generateMarkov() {
        var length = minLen + randomInt(maxLen - minLen + 1);
        var result = '';
        while (result.length < length) result += bigrams[randomInt(bigrams.length)];
        return result.substring(0, length);
      }

      var generators = {
        'leetspeak': generateLeetspeak,
        'phonetic': generatePhonetic,
        'pattern': generatePattern,
        'random': generateRandom,
        'markov': generateMarkov
      };

      var gen = generators[genType] || generateRandom;
      var passwords = [];
      for (var i = 0; i < count; i++) passwords.push(gen());
      return passwords;
    }
  };

  // Export Hash module
  window.__RESCRIPT_HASH__ = {
    hashPassword: async function(password, algorithm) {
      var algoMap = { 'md5': null, 'sha1': 'SHA-1', 'sha256': 'SHA-256', 'sha512': 'SHA-512' };
      var algoName = algoMap[algorithm];

      if (!algoName) {
        // Simple MD5 polyfill (NOT cryptographically secure)
        var hash = 0;
        for (var i = 0; i < password.length; i++) {
          hash = ((hash << 5) - hash) + password.charCodeAt(i);
          hash = hash & hash;
        }
        return Math.abs(hash).toString(16).padStart(32, '0');
      }

      var encoder = new TextEncoder();
      var data = encoder.encode(password);
      var hashBuffer = await crypto.subtle.digest(algoName, data);
      var hashArray = Array.from(new Uint8Array(hashBuffer));
      return hashArray.map(function(b) { return b.toString(16).padStart(2, '0'); }).join('');
    },

    isValidHash: function(hash, algorithm) {
      var lengths = { 'md5': 32, 'sha1': 40, 'sha256': 64, 'sha512': 128 };
      var expectedLength = lengths[algorithm];
      return hash.length === expectedLength && /^[a-fA-F0-9]+$/.test(hash);
    },

    crackHashFallback: async function(targetHash, algorithm, generator, maxAttempts) {
      var attempts = 0;
      for (var i = 0; i < maxAttempts; i++) {
        var password = window.__RESCRIPT_GENERATORS__.generate(generator, 1, 6, 16)[0];
        attempts++;
        var hash = await window.__RESCRIPT_HASH__.hashPassword(password, algorithm);
        if (hash.toLowerCase() === targetHash.toLowerCase()) {
          return { found: true, password: password, attempts: attempts };
        }
        if (attempts % 1000 === 0) await new Promise(function(r) { setTimeout(r, 0); });
      }
      return { found: false, password: null, attempts: attempts };
    }
  };
`)

// Trigger module loading
Console.log("ReScript modules loaded")
