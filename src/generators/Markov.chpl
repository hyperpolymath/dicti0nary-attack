/*
 * Markov Chain Password Generator
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 *
 * Generates pronounceable passwords using Markov chains trained on common passwords.
 * Markov models learn character/n-gram transition probabilities to create
 * realistic-looking but non-dictionary passwords.
 */

module Markov {
  use Map;
  use List;
  use Random;
  use CTypes;

  /*
   * Markov chain model
   *
   * Stores n-gram transition probabilities
   * Order 2: bigrams (ab → c)
   * Order 3: trigrams (abc → d)
   */
  record MarkovModel {
    var order: int = 2;
    var transitions: map(string, list(string));
    var startTokens: list(string);
    var trained: bool = false;

    /*
     * Add training example
     */
    proc addExample(text: string) {
      if text.size < order then return;

      const normalized = text.toLower();

      // Add start token
      const startNgram = normalized[0..<order];
      startTokens.pushBack(startNgram);

      // Build transition map
      for i in 0..(normalized.size - order - 1) {
        const ngram = normalized[i..<(i+order)];
        const nextChar = normalized[i+order];

        if !transitions.contains(ngram) {
          transitions[ngram] = new list(string);
        }

        transitions[ngram].pushBack(nextChar);
      }

      trained = true;
    }

    /*
     * Generate text from model
     */
    proc generate(minLength: int = 6, maxLength: int = 16): string {
      if !trained || startTokens.size == 0 then return "";

      var rng = new randomStream(eltType=real);

      // Pick random start token
      const startIdx = (rng.next() * startTokens.size): int;
      var result = startTokens[min(startIdx + 1, startTokens.size)];

      // Generate characters until we reach max length
      while result.size < maxLength {
        const ngram = result[(result.size - order)..];

        if !transitions.contains(ngram) then break;

        const nextOptions = transitions[ngram];
        if nextOptions.size == 0 then break;

        const nextIdx = (rng.next() * nextOptions.size): int;
        const nextChar = nextOptions[min(nextIdx + 1, nextOptions.size)];

        result += nextChar;

        // Stop if we've reached a good length
        if result.size >= minLength && rng.next() > 0.7 {
          break;
        }
      }

      return result;
    }
  }

  /*
   * Pre-trained model with common password patterns
   */
  var globalModel: MarkovModel;
  var modelInitialized: bool = false;

  /*
   * Initialize global model with training data
   */
  proc initializeModel(order: int = 2) {
    if modelInitialized then return;

    globalModel = new MarkovModel(order=order);

    // Training corpus: common password patterns
    const trainingData = [
      // Common passwords
      "password", "admin", "letmein", "welcome", "monkey",
      "dragon", "master", "sunshine", "princess", "starwars",
      "freedom", "whatever", "qwerty", "trustno", "batman",

      // Name-like patterns
      "jennifer", "michael", "jessica", "ashley", "matthew",
      "daniel", "andrew", "joshua", "christopher", "nicole",
      "amanda", "melissa", "robert", "william", "david",

      // Common words
      "computer", "internet", "security", "network", "digital",
      "technology", "software", "hardware", "system", "access",
      "login", "secure", "private", "secret", "hidden",

      // Pronounceable nonsense
      "xanadu", "zephyr", "azure", "crimson", "phoenix",
      "nexus", "vertex", "matrix", "quantum", "cipher",
      "mystic", "cosmic", "stellar", "lunar", "solar",

      // Gaming terms
      "gamer", "player", "winner", "champion", "legend",
      "ninja", "warrior", "knight", "wizard", "ranger",
      "paladin", "rogue", "hunter", "mage", "tank"
    ];

    for example in trainingData {
      globalModel.addExample(example);
    }

    modelInitialized = true;
  }

  /*
   * Generate Markov-based passwords
   *
   * Parameters:
   *   count - Number of passwords to generate
   *   minLength - Minimum password length
   *   maxLength - Maximum password length
   *   order - Markov chain order (2 or 3)
   *
   * Returns: Array of generated passwords
   */
  proc generate(count: int = 100,
                minLength: int = 6,
                maxLength: int = 16,
                order: int = 2): [] string {

    initializeModel(order);

    var passwords: [1..count] string;
    var rng = new randomStream(eltType=real);

    for i in 1..count {
      var password = globalModel.generate(minLength, maxLength);

      // Add variation: append numbers
      if rng.next() > 0.6 {
        const num = (rng.next() * 1000): int;
        password += num: string;
      }

      // Maybe capitalize first letter
      if rng.next() > 0.5 && password.size > 0 {
        password = password[0].toUpper() + password[1..];
      }

      // Ensure length constraints
      while password.size < minLength {
        const digit = (rng.next() * 10): int;
        password += digit: string;
      }

      if password.size > maxLength {
        password = password[0..<maxLength];
      }

      passwords[i] = password;
    }

    return passwords;
  }

  /*
   * Parallel Markov generation
   */
  proc generateParallel(count: int = 100,
                        minLength: int = 6,
                        maxLength: int = 16,
                        order: int = 2): [] string {

    initializeModel(order);

    var passwords: [1..count] string;

    forall i in 1..count {
      var rng = new randomStream(eltType=real, seed=i);
      var password = globalModel.generate(minLength, maxLength);

      // Add variation: append numbers
      if rng.next() > 0.6 {
        const num = (rng.next() * 1000): int;
        password += num: string;
      }

      // Maybe capitalize first letter
      if rng.next() > 0.5 && password.size > 0 {
        password = password[0].toUpper() + password[1..];
      }

      // Ensure length constraints
      while password.size < minLength {
        const digit = (rng.next() * 10): int;
        password += digit: string;
      }

      if password.size > maxLength {
        password = password[0..<maxLength];
      }

      passwords[i] = password;
    }

    return passwords;
  }

  /*
   * Train custom Markov model from wordlist
   *
   * Parameters:
   *   wordlist - Array of training examples
   *   order - Markov chain order
   *
   * Returns: Trained MarkovModel
   */
  proc trainModel(wordlist: [] string, order: int = 2): MarkovModel {
    var model = new MarkovModel(order=order);

    for word in wordlist {
      model.addExample(word);
    }

    return model;
  }

  /*
   * Generate passwords from custom model
   */
  proc generateFromModel(model: MarkovModel,
                         count: int = 100,
                         minLength: int = 6,
                         maxLength: int = 16): [] string {

    var passwords: [1..count] string;

    forall i in 1..count {
      var password = model.generate(minLength, maxLength);

      // Ensure minimum length
      while password.size < minLength {
        var rng = new randomStream(eltType=real, seed=i);
        const digit = (rng.next() * 10): int;
        password += digit: string;
      }

      // Truncate if too long
      if password.size > maxLength {
        password = password[0..<maxLength];
      }

      passwords[i] = password;
    }

    return passwords;
  }

  /*
   * WASM export for Markov generation
   */
  export proc generateMarkovWasm(count: int,
                                  minLength: int,
                                  maxLength: int,
                                  order: int,
                                  result: c_ptr(c_ptr(uint(8))),
                                  resultLen: c_ptr(int)): void {

    const passwords = generateParallel(count, minLength, maxLength, order);

    resultLen.deref() = passwords.size;

    // TODO: Copy to C memory
    for (i, pwd) in zip(1.., passwords) {
      // (result + i-1).deref() = allocateCString(pwd);
    }
  }

  /*
   * Calculate perplexity of generated passwords
   *
   * Lower perplexity = more similar to training data
   * Higher perplexity = more random/creative
   */
  proc calculatePerplexity(passwords: [] string): real {
    initializeModel();

    var totalLogProb = 0.0;
    var totalChars = 0;

    for password in passwords {
      const normalized = password.toLower();

      for i in 0..(normalized.size - globalModel.order - 1) {
        const ngram = normalized[i..<(i+globalModel.order)];
        const nextChar = normalized[i+globalModel.order];

        if globalModel.transitions.contains(ngram) {
          const nextOptions = globalModel.transitions[ngram];
          const prob = 1.0 / nextOptions.size;
          totalLogProb += log(prob);
          totalChars += 1;
        }
      }
    }

    const avgLogProb = totalLogProb / totalChars;
    const perplexity = exp(-avgLogProb);

    return perplexity;
  }

  /*
   * Benchmark Markov generation
   */
  proc benchmark(count: int = 10000) {
    use Time;

    writeln("Benchmarking Markov Chain Generation...");

    var timer: stopwatch;

    // Order 2 (bigrams)
    writeln("\n  Order 2 (bigrams):");
    timer.start();
    const passwords2 = generateParallel(count, 6, 16, order=2);
    timer.stop();
    const time2 = timer.elapsed();

    writeln("    Time:       ", time2, " seconds");
    writeln("    Rate:       ", (count / time2): int, " passwords/second");
    writeln("    Perplexity: ", calculatePerplexity(passwords2));

    // Order 3 (trigrams)
    writeln("\n  Order 3 (trigrams):");
    timer.clear();
    timer.start();
    const passwords3 = generateParallel(count, 6, 16, order=3);
    timer.stop();
    const time3 = timer.elapsed();

    writeln("    Time:       ", time3, " seconds");
    writeln("    Rate:       ", (count / time3): int, " passwords/second");
    writeln("    Perplexity: ", calculatePerplexity(passwords3));
  }

  /*
   * Main execution for testing
   */
  proc main() {
    writeln("=== Markov Chain Password Generator ===");
    writeln();

    // Order 2 (bigrams)
    writeln("Order 2 (Bigram) Passwords:");
    const samples2 = generate(10, 8, 14, order=2);
    for (i, pwd) in zip(1.., samples2) {
      writeln("  ", i, ". ", pwd);
    }
    writeln();

    // Order 3 (trigrams)
    writeln("Order 3 (Trigram) Passwords:");
    const samples3 = generate(10, 8, 14, order=3);
    for (i, pwd) in zip(1.., samples3) {
      writeln("  ", i, ". ", pwd);
    }
    writeln();

    // Custom training
    writeln("Custom Training (Tech Words):");
    const techWords = [
      "algorithm", "binary", "compiler", "database", "encryption",
      "firewall", "gateway", "hardware", "interface", "javascript",
      "kernel", "linux", "memory", "network", "operating",
      "protocol", "query", "router", "server", "terminal"
    ];
    var customModel = trainModel(techWords, order=2);
    const customPasswords = generateFromModel(customModel, 10, 8, 14);
    for (i, pwd) in zip(1.., customPasswords) {
      writeln("  ", i, ". ", pwd);
    }
    writeln();

    // Run benchmark
    benchmark(10000);
  }
}
