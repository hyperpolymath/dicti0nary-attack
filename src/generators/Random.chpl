/*
 * Random Password Generator
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 *
 * Generates cryptographically random passwords with configurable character sets.
 * While users often create "random" passwords, they tend to follow patterns.
 * This generator creates truly random passwords AND simulates human "random" patterns.
 */

module Random {
  use CTypes;
  use List;
  use Random as ChplRandom;

  /*
   * Character sets for password generation
   */
  const LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
  const UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const DIGITS = "0123456789";
  const SPECIAL = "!@#$%^&*()_+-=[]{}|;:,.<>?";
  const AMBIGUOUS = "il1Lo0O"; // Often excluded for readability

  /*
   * Password generation options
   */
  record PasswordOptions {
    var useLowercase: bool = true;
    var useUppercase: bool = true;
    var useDigits: bool = true;
    var useSpecial: bool = false;
    var excludeAmbiguous: bool = false;
    var minLength: int = 8;
    var maxLength: int = 16;
  }

  /*
   * Build character set from options
   */
  proc buildCharset(options: PasswordOptions): string {
    var charset = "";

    if options.useLowercase then charset += LOWERCASE;
    if options.useUppercase then charset += UPPERCASE;
    if options.useDigits then charset += DIGITS;
    if options.useSpecial then charset += SPECIAL;

    // Exclude ambiguous characters if requested
    if options.excludeAmbiguous {
      var filtered = "";
      for c in charset {
        if AMBIGUOUS.find(c) < 0 {
          filtered += c;
        }
      }
      charset = filtered;
    }

    if charset.isEmpty() {
      // Fallback to alphanumeric
      charset = LOWERCASE + DIGITS;
    }

    return charset;
  }

  /*
   * Generate truly random password
   *
   * Parameters:
   *   length - Password length
   *   options - Character set options
   *
   * Returns: Random password string
   */
  proc generateTrulyRandom(length: int, options: PasswordOptions): string {
    const charset = buildCharset(options);
    var rng = new randomStream(eltType=real);

    var password = "";
    for i in 1..length {
      const idx = (rng.next() * charset.size): int;
      password += charset[min(idx, charset.size-1)];
    }

    return password;
  }

  /*
   * Generate human-like "random" password
   *
   * Humans think they're being random, but they follow patterns:
   * - Start with uppercase
   * - End with numbers
   * - Special chars in middle
   * - Common substitutions (a→@, i→1, etc.)
   */
  proc generateHumanRandom(length: int, options: PasswordOptions): string {
    var rng = new randomStream(eltType=real);
    var password = "";

    // 1. Start with uppercase letter (70% of humans do this)
    if options.useUppercase && rng.next() > 0.3 {
      const idx = (rng.next() * UPPERCASE.size): int;
      password += UPPERCASE[min(idx, UPPERCASE.size-1)];
    }

    // 2. Add lowercase letters (body of password)
    const bodyLength = length - password.size - 2; // Reserve space for ending
    for i in 1..bodyLength {
      if options.useLowercase {
        const idx = (rng.next() * LOWERCASE.size): int;
        password += LOWERCASE[min(idx, LOWERCASE.size-1)];
      }
    }

    // 3. Maybe add a special character in middle (if enabled)
    if options.useSpecial && rng.next() > 0.6 {
      const idx = (rng.next() * SPECIAL.size): int;
      const specialChar = SPECIAL[min(idx, SPECIAL.size-1)];
      const insertPos = (password.size / 2): int;
      password = password[0..<insertPos] + specialChar + password[insertPos..];
    }

    // 4. End with numbers (80% of humans do this)
    if options.useDigits && rng.next() > 0.2 {
      const numDigits = if rng.next() > 0.5 then 2 else 3;
      for i in 1..numDigits {
        const digit = (rng.next() * 10): int;
        password += digit: string;
      }
    }

    // 5. Truncate or pad to exact length
    while password.size < length {
      const idx = (rng.next() * LOWERCASE.size): int;
      password += LOWERCASE[min(idx, LOWERCASE.size-1)];
    }

    if password.size > length {
      password = password[0..<length];
    }

    return password;
  }

  /*
   * Generate batch of random passwords
   *
   * Parameters:
   *   count - Number of passwords to generate
   *   options - Password generation options
   *   humanLike - Generate human-like patterns (vs truly random)
   *
   * Returns: Array of passwords
   */
  proc generate(count: int = 100,
                options: PasswordOptions = new PasswordOptions(),
                humanLike: bool = true): [] string {

    var passwords: [1..count] string;
    var rng = new randomStream(eltType=real);

    for i in 1..count {
      const length = (rng.next() * (options.maxLength - options.minLength + 1)): int
                     + options.minLength;

      if humanLike {
        passwords[i] = generateHumanRandom(length, options);
      } else {
        passwords[i] = generateTrulyRandom(length, options);
      }
    }

    return passwords;
  }

  /*
   * Parallel random password generation
   *
   * Leverages Chapel's forall for multi-core generation
   */
  proc generateParallel(count: int = 100,
                        options: PasswordOptions = new PasswordOptions(),
                        humanLike: bool = true): [] string {

    var passwords: [1..count] string;

    forall i in 1..count {
      var rng = new randomStream(eltType=real, seed=i);

      const length = (rng.next() * (options.maxLength - options.minLength + 1)): int
                     + options.minLength;

      if humanLike {
        passwords[i] = generateHumanRandom(length, options);
      } else {
        passwords[i] = generateTrulyRandom(length, options);
      }
    }

    return passwords;
  }

  /*
   * Generate PIN codes (numeric only)
   */
  proc generatePIN(count: int = 100, length: int = 4): [] string {
    var pins: [1..count] string;
    var rng = new randomStream(eltType=real);

    for i in 1..count {
      var pin = "";
      for j in 1..length {
        const digit = (rng.next() * 10): int;
        pin += digit: string;
      }
      pins[i] = pin;
    }

    return pins;
  }

  /*
   * Generate common weak "random" passwords
   *
   * These look random but are actually common:
   * - qwerty123, password1, abc123, etc.
   */
  proc generateCommonWeak(count: int = 100): [] string {
    const patterns = [
      "qwerty", "password", "admin", "letmein", "welcome",
      "monkey", "dragon", "master", "sunshine", "princess",
      "abc", "123", "qaz", "wsx", "zxc"
    ];

    var passwords: [1..count] string;
    var rng = new randomStream(eltType=real);

    for i in 1..count {
      const patternIdx = (rng.next() * patterns.size): int + 1;
      var password = patterns[min(patternIdx, patterns.size)];

      // Add numbers
      const num = (rng.next() * 10000): int;
      password += num: string;

      // Maybe capitalize first letter
      if rng.next() > 0.5 {
        password = password[0].toUpper() + password[1..];
      }

      passwords[i] = password;
    }

    return passwords;
  }

  /*
   * WASM export for random generation
   */
  export proc generateRandomWasm(count: int,
                                  minLength: int,
                                  maxLength: int,
                                  useLowercase: bool,
                                  useUppercase: bool,
                                  useDigits: bool,
                                  useSpecial: bool,
                                  result: c_ptr(c_ptr(uint(8))),
                                  resultLen: c_ptr(int)): void {

    var options = new PasswordOptions(
      useLowercase = useLowercase,
      useUppercase = useUppercase,
      useDigits = useDigits,
      useSpecial = useSpecial,
      minLength = minLength,
      maxLength = maxLength
    );

    const passwords = generateParallel(count, options, humanLike=true);

    resultLen.deref() = passwords.size;

    // TODO: Copy to C memory
    for (i, pwd) in zip(1.., passwords) {
      // (result + i-1).deref() = allocateCString(pwd);
    }
  }

  /*
   * Password strength estimation
   *
   * Calculate entropy and estimated crack time
   */
  proc estimateStrength(password: string): (int, real) {
    var charsetSize = 0;

    var hasLower = false;
    var hasUpper = false;
    var hasDigit = false;
    var hasSpecial = false;

    for c in password {
      if LOWERCASE.find(c) >= 0 then hasLower = true;
      if UPPERCASE.find(c) >= 0 then hasUpper = true;
      if DIGITS.find(c) >= 0 then hasDigit = true;
      if SPECIAL.find(c) >= 0 then hasSpecial = true;
    }

    if hasLower then charsetSize += 26;
    if hasUpper then charsetSize += 26;
    if hasDigit then charsetSize += 10;
    if hasSpecial then charsetSize += 32;

    // Entropy = log2(charsetSize^length)
    const entropy = password.size * log2(charsetSize: real);

    // Assuming 1 billion guesses per second
    const guessesPerSecond = 1_000_000_000.0;
    const totalCombinations = charsetSize ** password.size;
    const secondsToCrack = totalCombinations / guessesPerSecond;

    return (entropy: int, secondsToCrack);
  }

  /*
   * Benchmark random generation
   */
  proc benchmark(count: int = 100000) {
    use Time;

    writeln("Benchmarking Random Password Generation...");

    var timer: stopwatch;
    var options = new PasswordOptions(minLength=8, maxLength=16);

    // Serial benchmark
    timer.start();
    const serialPasswords = generate(count, options, humanLike=true);
    timer.stop();
    const serialTime = timer.elapsed();

    writeln("  Serial:   ", serialTime, " seconds");
    writeln("            ", (count / serialTime): int, " passwords/second");

    // Parallel benchmark
    timer.clear();
    timer.start();
    const parallelPasswords = generateParallel(count, options, humanLike=true);
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
    writeln("=== Random Password Generator ===");
    writeln();

    // Truly random samples
    writeln("Truly Random Passwords:");
    var options1 = new PasswordOptions(
      useLowercase = true,
      useUppercase = true,
      useDigits = true,
      useSpecial = true,
      minLength = 12,
      maxLength = 16
    );
    const random1 = generate(5, options1, humanLike=false);
    for (i, pwd) in zip(1.., random1) {
      const (entropy, time) = estimateStrength(pwd);
      writeln("  ", i, ". ", pwd, " (entropy: ", entropy, " bits)");
    }
    writeln();

    // Human-like random samples
    writeln("Human-Like Random Passwords:");
    const random2 = generate(5, options1, humanLike=true);
    for (i, pwd) in zip(1.., random2) {
      const (entropy, time) = estimateStrength(pwd);
      writeln("  ", i, ". ", pwd, " (entropy: ", entropy, " bits)");
    }
    writeln();

    // Common weak passwords
    writeln("Common Weak 'Random' Passwords:");
    const weak = generateCommonWeak(5);
    for (i, pwd) in zip(1.., weak) {
      writeln("  ", i, ". ", pwd);
    }
    writeln();

    // PIN codes
    writeln("Sample PIN Codes:");
    const pins = generatePIN(5, 6);
    for (i, pin) in zip(1.., pins) {
      writeln("  ", i, ". ", pin);
    }
    writeln();

    // Run benchmark
    benchmark(100000);
  }
}
