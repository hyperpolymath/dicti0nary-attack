# Nickel Configuration for dicti0nary-attack
# Type-safe, programmable configuration
#
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Security Research Team

{
  # Base configuration shared across all variants
  base = {
    app = {
      name = "dicti0nary-attack",
      version = "0.1.0",
      description = "Non-dictionary password research tool",
    },

    generators = {
      leetspeak = {
        max_substitutions = 3,
        min_length = 6,
        max_length = 16,
      },

      phonetic = {
        case_variations = true,
        min_length = 4,
        max_length = 20,
      },

      pattern = {
        min_length = 6,
        max_length = 16,
        include_keyboard_walks = true,
        include_sequences = true,
        include_dates = true,
      },

      random = {
        min_length = 8,
        max_length = 16,
        use_uppercase = true,
        use_lowercase = true,
        use_digits = true,
        use_special = false,
      },

      markov = {
        order = 2,
        min_length = 6,
        max_length = 16,
      },
    },

    cracker = {
      default_algorithm = "SHA256",
      parallel_tasks = 4,
      batch_size = 1000,
    },

    output = {
      directory = "output",
      format = "text",
      save_stats = true,
    },

    wasm = {
      threads = 4,
      memory = "256MB",
      stack_size = "1MB",
    },

    1000langs = {
      enabled = true,
      vendor_path = "vendor/1000Langs",
      default_language = "en",
      extract_languages = ["en", "es", "fr", "de", "zh", "ar", "hi"],
    },
  },

  # Development configuration
  dev = base & {
    app.env = "development",
    output.directory = "output/dev",
    cracker.parallel_tasks = 2,  # Lower for dev
    wasm.memory = "128MB",
    logging = {
      level = "DEBUG",
      file = "dicti0nary-dev.log",
    },
  },

  # Production configuration
  prod = base & {
    app.env = "production",
    output.directory = "output/prod",
    cracker.parallel_tasks = 8,  # Max performance
    wasm.memory = "512MB",
    wasm.threads = 8,
    logging = {
      level = "INFO",
      file = null,  # No file logging in prod
    },
    optimizations = {
      enable_fast_math = true,
      inline_threshold = 1000,
    },
  },

  # Test configuration
  test = base & {
    app.env = "test",
    output.directory = "output/test",
    generators.leetspeak.max_substitutions = 1,  # Faster tests
    generators.pattern.min_length = 4,
    cracker.parallel_tasks = 2,
    cracker.batch_size = 100,
    wasm.memory = "64MB",
    logging = {
      level = "DEBUG",
      file = "dicti0nary-test.log",
    },
  },

  # Infinite arity CLI configuration combos
  cli_variants = {
    # Fast mode: Optimized for speed
    fast = prod & {
      cracker.parallel_tasks = 16,
      wasm.threads = 16,
      generators.pattern.min_length = 6,  # Skip very short
    },

    # Thorough mode: Maximum coverage
    thorough = prod & {
      generators.leetspeak.max_substitutions = 5,
      generators.pattern.max_length = 24,
      cracker.batch_size = 5000,
    },

    # CTF mode: Quick iteration for competitions
    ctf = dev & {
      generators.pattern.min_length = 4,
      generators.pattern.max_length = 12,
      cracker.parallel_tasks = 4,
      output.format = "json",
    },

    # Research mode: Multilingual focus
    research = prod & {
      "1000langs".extract_languages = [
        "en", "es", "fr", "de", "it", "pt", "ru", "zh",
        "ja", "ko", "ar", "hi", "bn", "pa", "te", "mr",
      ],
      generators.markov.order = 3,  # More context
      output.save_stats = true,
      output.format = "json",
    },

    # Minimal mode: Embedded/resource-constrained
    minimal = base & {
      wasm.memory = "32MB",
      wasm.threads = 1,
      cracker.parallel_tasks = 1,
      generators.leetspeak.max_substitutions = 2,
    },
  },

  # RSR Framework compliance settings
  rsr = {
    level = "bronze",
    score = 86,
    perimeter = 3,
    offline_first = true,
    type_safety = "chapel",
    memory_safety = "chapel",
  },
}
