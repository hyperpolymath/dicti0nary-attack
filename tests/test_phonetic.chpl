/*
 * Tests for Phonetic Password Generator
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 */

use Phonetic;
use UnitTest;

proc testPhoneticGeneration(test: borrowed Test) throws {
  writeln("Testing Phonetic password generation...");

  // Test basic generation
  const passwords = Phonetic.generate(count=10, minLength=6, maxLength=16);

  test.assertTrue(passwords.size == 10, "Should generate 10 passwords");

  for pwd in passwords {
    test.assertTrue(pwd.size >= 6, "Password should be at least 6 characters");
    test.assertTrue(pwd.size <= 16, "Password should be at most 16 characters");
    test.assertTrue(pwd.size > 0, "Password should not be empty");
  }

  writeln("  ✓ Basic generation test passed");
}

proc testPhoneticParallel(test: borrowed Test) throws {
  writeln("Testing parallel phonetic generation...");

  const passwords = Phonetic.generateParallel(count=100, minLength=8, maxLength=12);

  test.assertTrue(passwords.size == 100, "Should generate 100 passwords");

  for pwd in passwords {
    test.assertTrue(pwd.size >= 8, "Password should be at least 8 characters");
    test.assertTrue(pwd.size <= 12, "Password should be at most 12 characters");
  }

  writeln("  ✓ Parallel generation test passed");
}

proc testPhoneticSubstitutions(test: borrowed Test) throws {
  writeln("Testing phonetic substitutions...");

  const result = Phonetic.applyPhoneticSubs("password", maxSubs=3, caseVariation=false);

  // Should contain some phonetic substitution
  test.assertTrue(result.size > 0, "Result should not be empty");
  test.assertFalse(result == "password", "Should apply substitutions");

  writeln("  ✓ Substitution test passed");
}

proc main() {
  writeln("═══════════════════════════════════════════════════════════════");
  writeln("  Phonetic Generator Test Suite");
  writeln("═══════════════════════════════════════════════════════════════");
  writeln();

  var test = new owned UnitTest();

  testPhoneticGeneration(test.borrow());
  testPhoneticParallel(test.borrow());
  testPhoneticSubstitutions(test.borrow());

  writeln();
  writeln("═══════════════════════════════════════════════════════════════");
  writeln("✓ All Phonetic tests passed!");
  writeln("═══════════════════════════════════════════════════════════════");
}
