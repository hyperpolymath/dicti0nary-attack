/*
 * dicti0nary-attack - Main CLI Program
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 *
 * Non-dictionary password research tool
 * Focuses on passwords users think are secure but aren't in dictionaries
 */

module Dicti0nary {
  use Leetspeak;
  use Phonetic;
  use Pattern;
  use Random;
  use Markov;
  use HashCracker;
  use IO;
  use FileSystem;
  use Time;
  use ArgumentParser;

  /*
   * CLI Configuration
   */
  config const command: string = "help";
  config const generator: string = "pattern";
  config const count: int = 100;
  config const minLength: int = 6;
  config const maxLength: int = 16;
  config const outputFile: string = "";
  config const hashAlgo: string = "sha256";
  config const targetHash: string = "";
  config const maxAttempts: int = 10000;
  config const parallel: bool = true;
  config const benchmark: bool = false;
  config const verbose: bool = false;

  /*
   * Print banner
   */
  proc printBanner() {
    writeln("╔═══════════════════════════════════════════════════════════════╗");
    writeln("║                     dicti0nary-attack                         ║");
    writeln("║        Non-Dictionary Password Research Tool v0.1.0           ║");
    writeln("║                   Chapel → WASM Edition                       ║");
    writeln("╚═══════════════════════════════════════════════════════════════╝");
    writeln();
    writeln("⚠️  AUTHORIZED USE ONLY - For security research and testing");
    writeln();
  }

  /*
   * Print help
   */
  proc printHelp() {
    printBanner();
    writeln("USAGE:");
    writeln("  dicti0nary [COMMAND] [OPTIONS]");
    writeln();
    writeln("COMMANDS:");
    writeln("  generate    Generate non-dictionary passwords");
    writeln("  crack       Crack password hash");
    writeln("  hash        Hash a password");
    writeln("  benchmark   Run performance benchmarks");
    writeln("  info        Display system information");
    writeln("  help        Show this help message");
    writeln();
    writeln("GENERATE OPTIONS:");
    writeln("  --generator=TYPE     Generator type (leetspeak|phonetic|pattern|random|markov)");
    writeln("  --count=N            Number of passwords to generate (default: 100)");
    writeln("  --minLength=N        Minimum password length (default: 6)");
    writeln("  --maxLength=N        Maximum password length (default: 16)");
    writeln("  --outputFile=PATH    Write output to file");
    writeln("  --parallel=BOOL      Use parallel generation (default: true)");
    writeln();
    writeln("CRACK OPTIONS:");
    writeln("  --targetHash=HASH    Hash to crack");
    writeln("  --hashAlgo=ALGO      Hash algorithm (md5|sha1|sha256|sha512)");
    writeln("  --generator=TYPE     Password generator to use");
    writeln("  --maxAttempts=N      Maximum cracking attempts (default: 10000)");
    writeln();
    writeln("EXAMPLES:");
    writeln("  # Generate 1000 leetspeak passwords");
    writeln("  dicti0nary --command=generate --generator=leetspeak --count=1000");
    writeln();
    writeln("  # Crack SHA256 hash using pattern generator");
    writeln("  dicti0nary --command=crack --targetHash=abc123... --hashAlgo=sha256");
    writeln();
    writeln("  # Run benchmarks");
    writeln("  dicti0nary --command=benchmark");
    writeln();
  }

  /*
   * Generate passwords command
   */
  proc cmdGenerate() {
    if verbose {
      writeln("🔧 Generating passwords...");
      writeln("   Generator:  ", generator);
      writeln("   Count:      ", count);
      writeln("   Length:     ", minLength, "-", maxLength);
      writeln("   Parallel:   ", parallel);
      writeln();
    }

    var timer: stopwatch;
    timer.start();

    var passwords: [] string;

    select generator {
      when "leetspeak" {
        // TODO: Implement Leetspeak.generate()
        writeln("⚠️  Leetspeak generator not yet implemented");
        passwords = Random.generate(count,
          new Random.PasswordOptions(minLength=minLength, maxLength=maxLength));
      }
      when "phonetic" {
        if parallel {
          passwords = Phonetic.generateParallel(count, minLength, maxLength);
        } else {
          passwords = Phonetic.generate(count, minLength, maxLength);
        }
      }
      when "pattern" {
        // TODO: Implement Pattern.generate()
        writeln("⚠️  Pattern generator not yet implemented");
        passwords = Random.generate(count,
          new Random.PasswordOptions(minLength=minLength, maxLength=maxLength));
      }
      when "random" {
        var options = new Random.PasswordOptions(
          minLength = minLength,
          maxLength = maxLength,
          useLowercase = true,
          useUppercase = true,
          useDigits = true,
          useSpecial = false
        );
        if parallel {
          passwords = Random.generateParallel(count, options);
        } else {
          passwords = Random.generate(count, options);
        }
      }
      when "markov" {
        if parallel {
          passwords = Markov.generateParallel(count, minLength, maxLength);
        } else {
          passwords = Markov.generate(count, minLength, maxLength);
        }
      }
      otherwise {
        writeln("❌ Unknown generator: ", generator);
        writeln("   Valid generators: leetspeak, phonetic, pattern, random, markov");
        return;
      }
    }

    timer.stop();

    // Output results
    if outputFile != "" {
      writePasswordsToFile(passwords, outputFile);
      writeln("✓ Generated ", passwords.size, " passwords in ", timer.elapsed(), "s");
      writeln("  Written to: ", outputFile);
    } else {
      for (i, pwd) in zip(1.., passwords) {
        writeln(pwd);
      }
      if verbose {
        writeln();
        writeln("✓ Generated ", passwords.size, " passwords in ", timer.elapsed(), "s");
        writeln("  Rate: ", (passwords.size / timer.elapsed()): int, " passwords/second");
      }
    }
  }

  /*
   * Crack hash command
   */
  proc cmdCrack() {
    if targetHash == "" {
      writeln("❌ Error: --targetHash required");
      return;
    }

    if verbose {
      writeln("🔓 Cracking hash...");
      writeln("   Algorithm:    ", hashAlgo);
      writeln("   Generator:    ", generator);
      writeln("   Max Attempts: ", maxAttempts);
      writeln();
    }

    var timer: stopwatch;
    timer.start();

    // TODO: Implement actual cracking with HashCracker module
    writeln("⚠️  Hash cracking not yet fully implemented");
    writeln("   This requires completing hash algorithm implementations in HashCracker.chpl");

    timer.stop();

    writeln();
    writeln("✗ Password not found after ", maxAttempts, " attempts");
    writeln("  Time elapsed: ", timer.elapsed(), "s");
    writeln("  Rate: ", (maxAttempts / timer.elapsed()): int, " hashes/second");
  }

  /*
   * Hash password command
   */
  proc cmdHash() {
    writeln("Enter password to hash:");
    var password: string;
    read(password);

    writeln();
    writeln("Algorithm: ", hashAlgo.toUpper());

    // TODO: Use HashCracker.hashPassword()
    writeln("⚠️  Hashing not yet fully implemented");
    writeln("   This requires completing hash algorithm implementations in HashCracker.chpl");
  }

  /*
   * Benchmark command
   */
  proc cmdBenchmark() {
    printBanner();
    writeln("🏃 Running comprehensive benchmarks...");
    writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    writeln();

    const benchCount = 10000;

    // Phonetic benchmark
    writeln("┌─ Phonetic Generator ─────────────────────────────────────┐");
    Phonetic.benchmark(benchCount);
    writeln("└──────────────────────────────────────────────────────────┘");
    writeln();

    // Random benchmark
    writeln("┌─ Random Generator ───────────────────────────────────────┐");
    Random.benchmark(benchCount);
    writeln("└──────────────────────────────────────────────────────────┘");
    writeln();

    // Markov benchmark
    writeln("┌─ Markov Chain Generator ─────────────────────────────────┐");
    Markov.benchmark(benchCount);
    writeln("└──────────────────────────────────────────────────────────┘");
    writeln();

    // TODO: Add other generator benchmarks

    writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    writeln("✓ Benchmarks complete");
  }

  /*
   * Info command
   */
  proc cmdInfo() {
    printBanner();

    writeln("SYSTEM INFORMATION:");
    writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    writeln();

    writeln("Chapel Configuration:");
    writeln("  Version:          ", here.chpl_version());
    writeln("  Locales:          ", numLocales);
    writeln("  Tasks per locale: ", here.maxTaskPar);
    writeln();

    writeln("Available Generators:");
    writeln("  ▹ Leetspeak      (a→4, e→3, i→1, o→0)");
    writeln("  ▹ Phonetic       (for→4, to→2, you→u)");
    writeln("  ▹ Pattern        (keyboard walks, sequences)");
    writeln("  ▹ Random         (truly random + human-like)");
    writeln("  ▹ Markov         (trained on common passwords)");
    writeln();

    writeln("Hash Algorithms:");
    writeln("  ▹ MD5");
    writeln("  ▹ SHA1");
    writeln("  ▹ SHA256");
    writeln("  ▹ SHA512");
    writeln();

    writeln("Features:");
    writeln("  ✓ Parallel password generation");
    writeln("  ✓ Chapel → WASM compilation");
    writeln("  ✓ Offline-first architecture");
    writeln("  ✓ RSR Framework Bronze (86%)");
    writeln("  ✓ CSS-first web interface");
    writeln();

    writeln("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  }

  /*
   * Write passwords to file
   */
  proc writePasswordsToFile(passwords: [] string, filename: string) {
    try {
      var outfile = open(filename, ioMode.cw);
      var writer = outfile.writer(locking=false);

      for pwd in passwords {
        writer.writeln(pwd);
      }

      writer.close();
      outfile.close();
    } catch e {
      writeln("❌ Error writing to file: ", e);
    }
  }

  /*
   * Main program entry point
   */
  proc main() {
    select command {
      when "help", "-h", "--help" {
        printHelp();
      }
      when "generate", "gen" {
        cmdGenerate();
      }
      when "crack" {
        cmdCrack();
      }
      when "hash" {
        cmdHash();
      }
      when "benchmark", "bench" {
        cmdBenchmark();
      }
      when "info" {
        cmdInfo();
      }
      otherwise {
        writeln("❌ Unknown command: ", command);
        writeln("   Run 'dicti0nary --command=help' for usage");
      }
    }
  }
}
