/*
 * Tests for Markov Chain Password Generator
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Security Research Team
 */

use Markov;
use UnitTest;

proc testMarkovGeneration(test: borrowed Test) throws {
  writeln("Testing Markov chain password generation...");

  const passwords = Markov.generate(count=10, minLength=6, maxLength=16, order=2);

  test.assertTrue(passwords.size == 10, "Should generate 10 passwords");

  for pwd in passwords {
    test.assertTrue(pwd.size >= 6, "Password should be at least 6 characters");
    test.assertTrue(pwd.size <= 16, "Password should be at most 16 characters");
    test.assertTrue(pwd.size > 0, "Password should not be empty");
  }

  writeln("  ✓ Basic generation test passed");
}

proc testMarkovOrders(test: borrowed Test) throws {
  writeln("Testing different Markov orders...");

  // Order 2 (bigrams)
  const passwords2 = Markov.generate(count=10, minLength=8, maxLength=12, order=2);
  test.assertTrue(passwords2.size == 10, "Order 2 should generate 10 passwords");

  // Order 3 (trigrams)
  const passwords3 = Markov.generate(count=10, minLength=8, maxLength=12, order=3);
  test.assertTrue(passwords3.size == 10, "Order 3 should generate 10 passwords");

  writeln("  ✓ Different orders test passed");
}

proc testMarkovParallel(test: borrowed Test) throws {
  writeln("Testing parallel Markov generation...");

  const passwords = Markov.generateParallel(count=100, minLength=6, maxLength=14, order=2);

  test.assertTrue(passwords.size == 100, "Should generate 100 passwords");

  for pwd in passwords {
    test.assertTrue(pwd.size >= 6, "Password should be at least 6 characters");
    test.assertTrue(pwd.size <= 14, "Password should be at most 14 characters");
  }

  writeln("  ✓ Parallel generation test passed");
}

proc testCustomModelTraining(test: borrowed Test) throws {
  writeln("Testing custom model training...");

  const trainingWords = [
    "security", "password", "system", "network", "computer",
    "digital", "crypto", "cipher", "algorithm", "protocol"
  ];

  var model = Markov.trainModel(trainingWords, order=2);

  test.assertTrue(model.trained, "Model should be marked as trained");
  test.assertTrue(model.startTokens.size > 0, "Should have start tokens");

  // Generate from custom model
  const passwords = Markov.generateFromModel(model, count=10, minLength=6, maxLength=16);

  test.assertTrue(passwords.size == 10, "Should generate 10 passwords from custom model");

  writeln("  ✓ Custom model training test passed");
}

proc testPerplexityCalculation(test: borrowed Test) throws {
  writeln("Testing perplexity calculation...");

  const passwords = Markov.generate(count=20, minLength=8, maxLength=12, order=2);
  const perplexity = Markov.calculatePerplexity(passwords);

  test.assertTrue(perplexity > 0, "Perplexity should be positive");
  test.assertTrue(perplexity < 1000, "Perplexity should be reasonable");

  writeln("  ✓ Perplexity calculation test passed");
}

proc main() {
  writeln("═══════════════════════════════════════════════════════════════");
  writeln("  Markov Chain Generator Test Suite");
  writeln("═══════════════════════════════════════════════════════════════");
  writeln();

  var test = new owned UnitTest();

  testMarkovGeneration(test.borrow());
  testMarkovOrders(test.borrow());
  testMarkovParallel(test.borrow());
  testCustomModelTraining(test.borrow());
  testPerplexityCalculation(test.borrow());

  writeln();
  writeln("═══════════════════════════════════════════════════════════════");
  writeln("✓ All Markov tests passed!");
  writeln("═══════════════════════════════════════════════════════════════");
}
