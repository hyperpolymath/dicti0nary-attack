/*
 * Tests for Random Password Generator
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 */

use Random;
use UnitTest;

proc testRandomGeneration(test: borrowed Test) throws {
  writeln("Testing Random password generation...");

  var options = new Random.PasswordOptions(
    useLowercase = true,
    useUppercase = true,
    useDigits = true,
    useSpecial = false,
    minLength = 8,
    maxLength = 16
  );

  const passwords = Random.generate(count=10, options=options, humanLike=false);

  test.assertTrue(passwords.size == 10, "Should generate 10 passwords");

  for pwd in passwords {
    test.assertTrue(pwd.size >= 8, "Password should be at least 8 characters");
    test.assertTrue(pwd.size <= 16, "Password should be at most 16 characters");
  }

  writeln("  ✓ Basic generation test passed");
}

proc testHumanLikeGeneration(test: borrowed Test) throws {
  writeln("Testing human-like random generation...");

  var options = new Random.PasswordOptions(
    minLength = 10,
    maxLength = 14
  );

  const passwords = Random.generate(count=20, options=options, humanLike=true);

  test.assertTrue(passwords.size == 20, "Should generate 20 passwords");

  // Check that at least some passwords start with uppercase (human pattern)
  var uppercaseStarts = 0;
  for pwd in passwords {
    if pwd[0] >= 'A' && pwd[0] <= 'Z' {
      uppercaseStarts += 1;
    }
  }

  test.assertTrue(uppercaseStarts > 0, "Some passwords should start with uppercase");

  writeln("  ✓ Human-like generation test passed");
}

proc testPINGeneration(test: borrowed Test) throws {
  writeln("Testing PIN code generation...");

  const pins = Random.generatePIN(count=10, length=6);

  test.assertTrue(pins.size == 10, "Should generate 10 PINs");

  for pin in pins {
    test.assertTrue(pin.size == 6, "PIN should be 6 digits");

    // Check all characters are digits
    for c in pin {
      test.assertTrue(c >= '0' && c <= '9', "PIN should contain only digits");
    }
  }

  writeln("  ✓ PIN generation test passed");
}

proc testPasswordStrength(test: borrowed Test) throws {
  writeln("Testing password strength estimation...");

  const weakPassword = "abc123";
  const strongPassword = "Xk9#mP2vL@3nQ8";

  const (weakEntropy, weakTime) = Random.estimateStrength(weakPassword);
  const (strongEntropy, strongTime) = Random.estimateStrength(strongPassword);

  test.assertTrue(strongEntropy > weakEntropy, "Strong password should have higher entropy");

  writeln("  ✓ Strength estimation test passed");
}

proc testParallelGeneration(test: borrowed Test) throws {
  writeln("Testing parallel random generation...");

  var options = new Random.PasswordOptions(minLength=8, maxLength=16);
  const passwords = Random.generateParallel(count=100, options=options);

  test.assertTrue(passwords.size == 100, "Should generate 100 passwords");

  writeln("  ✓ Parallel generation test passed");
}

proc main() {
  writeln("═══════════════════════════════════════════════════════════════");
  writeln("  Random Generator Test Suite");
  writeln("═══════════════════════════════════════════════════════════════");
  writeln();

  var test = new owned UnitTest();

  testRandomGeneration(test.borrow());
  testHumanLikeGeneration(test.borrow());
  testPINGeneration(test.borrow());
  testPasswordStrength(test.borrow());
  testParallelGeneration(test.borrow());

  writeln();
  writeln("═══════════════════════════════════════════════════════════════");
  writeln("✓ All Random tests passed!");
  writeln("═══════════════════════════════════════════════════════════════");
}
