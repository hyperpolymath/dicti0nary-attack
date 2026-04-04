/*
 * Phonetic Substitution Password Generator
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 *
 * Generates passwords using phonetic substitutions:
 * - "for" → "4"
 * - "to" → "2"
 * - "you" → "u"
 * - "are" → "r"
 * - "see" → "c"
 * - "why" → "y"
 */

module Phonetic {
  use Map;
  use List;
  use Random;
  use CTypes;

  /*
   * Phonetic substitution map
   * Maps common phonetic patterns to their numeric/symbolic equivalents
   */
  private const phoneticMap: [1..20] (string, string) = [
    ("for", "4"),
    ("to", "2"),
    ("too", "2"),
    ("you", "u"),
    ("your", "ur"),
    ("are", "r"),
    ("see", "c"),
    ("sea", "c"),
    ("why", "y"),
    ("at", "@"),
    ("ate", "8"),
    ("be", "b"),
    ("bee", "b"),
    ("eye", "i"),
    ("oh", "0"),
    ("one", "1"),
    ("won", "1"),
    ("two", "2"),
    ("three", "3"),
    ("four", "4")
  ];

  /*
   * Common base words for phonetic variation
   */
  private const baseWords: [1..30] string = [
    "password", "access", "secure", "login", "admin",
    "system", "enter", "unlock", "welcome", "private",
    "secret", "master", "super", "power", "elite",
    "ninja", "dragon", "phoenix", "eagle", "tiger",
    "warrior", "knight", "magic", "cyber", "digital",
    "cloud", "network", "online", "virtual", "quantum"
  ];

  /*
   * Apply phonetic substitutions to a word
   *
   * Parameters:
   *   word - Base word to transform
   *   maxSubs - Maximum number of substitutions (0 = unlimited)
   *   caseVariation - Apply random case changes
   *
   * Returns: Phonetically transformed word
   */
  proc applyPhoneticSubs(word: string, maxSubs: int = 0, caseVariation: bool = true): string {
    var result = word.toLower();
    var subsApplied = 0;

    // Apply phonetic substitutions
    for (pattern, replacement) in phoneticMap {
      if maxSubs > 0 && subsApplied >= maxSubs then break;

      if result.find(pattern) >= 0 {
        result = result.replace(pattern, replacement);
        subsApplied += 1;
      }
    }

    // Apply case variations
    if caseVariation {
      var chars: list(string);
      for c in result {
        if Random.fillRandom() > 0.5 {
          chars.pushBack(c.toUpper());
        } else {
          chars.pushBack(c);
        }
      }
      result = "".join(chars);
    }

    return result;
  }

  /*
   * Generate phonetic password variations
   *
   * Parameters:
   *   baseWord - Word to generate variations from
   *   count - Number of variations to generate
   *   minLength - Minimum password length
   *   maxLength - Maximum password length
   *
   * Returns: Iterator of phonetic password variations
   */
  iter generateVariations(baseWord: string, count: int = 10,
                          minLength: int = 4, maxLength: int = 20): string {

    var rng = new randomStream(eltType=real);

    for i in 1..count {
      var password = applyPhoneticSubs(baseWord, maxSubs=3, caseVariation=true);

      // Add numbers/symbols to meet length requirements
      while password.size < minLength {
        const digit = (rng.next() * 10): int;
        password += digit: string;
      }

      // Truncate if too long
      if password.size > maxLength {
        password = password[0..<maxLength];
      }

      // Add variation: prepend/append numbers
      if rng.next() > 0.5 {
        const num = (rng.next() * 1000): int;
        password = num: string + password;
      } else {
        const num = (rng.next() * 1000): int;
        password += num: string;
      }

      // Final length check
      if password.size >= minLength && password.size <= maxLength {
        yield password;
      }
    }
  }

  /*
   * Generate phonetic passwords from word list
   *
   * Parameters:
   *   count - Number of passwords to generate
   *   minLength - Minimum password length
   *   maxLength - Maximum password length
   *
   * Returns: Array of generated passwords
   */
  proc generate(count: int = 100, minLength: int = 6, maxLength: int = 16): [] string {
    var passwords: [1..count] string;
    var rng = new randomStream(eltType=real);
    var idx = 1;

    while idx <= count {
      // Pick random base word
      const wordIdx = (rng.next() * baseWords.size): int + 1;
      const baseWord = baseWords[min(wordIdx, baseWords.size)];

      // Generate variation
      var password = applyPhoneticSubs(baseWord, maxSubs=2, caseVariation=true);

      // Add suffix number
      const suffix = (rng.next() * 10000): int;
      password += suffix: string;

      // Adjust length
      if password.size < minLength {
        while password.size < minLength {
          const digit = (rng.next() * 10): int;
          password += digit: string;
        }
      }

      if password.size > maxLength {
        password = password[0..<maxLength];
      }

      if password.size >= minLength && password.size <= maxLength {
        passwords[idx] = password;
        idx += 1;
      }
    }

    return passwords;
  }

  /*
   * Parallel phonetic password generation
   *
   * Leverages Chapel's data parallelism for multi-core performance
   */
  proc generateParallel(count: int = 100, minLength: int = 6, maxLength: int = 16): [] string {
    var passwords: [1..count] string;

    forall i in 1..count {
      var rng = new randomStream(eltType=real, seed=i);

      // Pick random base word
      const wordIdx = (rng.next() * baseWords.size): int + 1;
      const baseWord = baseWords[min(wordIdx, baseWords.size)];

      // Generate variation
      var password = applyPhoneticSubs(baseWord, maxSubs=2, caseVariation=true);

      // Add suffix
      const suffix = (rng.next() * 10000): int;
      password += suffix: string;

      // Adjust length
      if password.size < minLength {
        while password.size < minLength {
          const digit = (rng.next() * 10): int;
          password += digit: string;
        }
      }

      if password.size > maxLength {
        password = password[0..<maxLength];
      }

      passwords[i] = password;
    }

    return passwords;
  }

  /*
   * WASM export for phonetic generation
   */
  export proc generatePhoneticWasm(count: int,
                                    minLength: int,
                                    maxLength: int,
                                    result: c_ptr(c_ptr(uint(8))),
                                    resultLen: c_ptr(int)): void {

    const passwords = generateParallel(count, minLength, maxLength);

    // Convert Chapel strings to C string array
    // TODO: Proper C string allocation and copying
    resultLen.deref() = passwords.size;

    for (i, pwd) in zip(1.., passwords) {
      // Copy password to C memory
      // (result + i-1).deref() = allocateCString(pwd);
    }
  }

  /*
   * Benchmark phonetic generation
   */
  proc benchmark(count: int = 10000) {
    use Time;

    writeln("Benchmarking Phonetic Generation...");

    var timer: stopwatch;

    // Serial benchmark
    timer.start();
    const serialPasswords = generate(count, 6, 16);
    timer.stop();
    const serialTime = timer.elapsed();

    writeln("  Serial:   ", serialTime, " seconds");
    writeln("            ", (count / serialTime): int, " passwords/second");

    // Parallel benchmark
    timer.clear();
    timer.start();
    const parallelPasswords = generateParallel(count, 6, 16);
    timer.stop();
    const parallelTime = timer.elapsed();

    writeln("  Parallel: ", parallelTime, " seconds");
    writeln("            ", (count / parallelTime): int, " passwords/second");
    writeln("  Speedup:  ", (serialTime / parallelTime), "x");
  }

  /*
   * Main execution for testing
   */
  proc main() {
    writeln("=== Phonetic Password Generator ===");
    writeln();

    // Generate sample passwords
    writeln("Sample Phonetic Passwords:");
    const samples = generate(10, 8, 16);
    for (i, pwd) in zip(1.., samples) {
      writeln("  ", i, ". ", pwd);
    }
    writeln();

    // Run benchmark
    benchmark(10000);
  }
}
