//! Pattern-based password generator
//!
//! Generates passwords matching common patterns like word+number, etc.

use dicti0nary_attack_core::{GeneratorConfig, PasswordGenerator, Result};
use rand::Rng;

/// Generator that creates passwords following common patterns
pub struct PatternGenerator;

impl PatternGenerator {
    pub fn new() -> Self {
        Self
    }
}

impl Default for PatternGenerator {
    fn default() -> Self {
        Self::new()
    }
}

impl PasswordGenerator for PatternGenerator {
    fn name(&self) -> &str {
        "pattern"
    }

    fn generate(&self, config: &GeneratorConfig) -> Result<Vec<String>> {
        let mut rng = rand::thread_rng();
        let mut passwords = Vec::new();

        let base_words = vec![
            "password", "admin", "user", "login", "welcome", "hello",
            "secret", "dragon", "master", "monkey", "love", "sunshine",
            "princess", "football", "baseball", "iloveyou", "trustno1",
        ];

        let suffixes = vec![
            "123", "1234", "12345", "!", "!!", "123!", "2024", "2025",
            "01", "99", "00", "007", "@123", "#1",
        ];

        let prefixes = vec!["", "My", "The", "1", "123"];

        for _ in 0..config.count {
            let base = base_words[rng.gen_range(0..base_words.len())];
            let suffix = suffixes[rng.gen_range(0..suffixes.len())];
            let prefix = prefixes[rng.gen_range(0..prefixes.len())];

            let password = format!("{}{}{}", prefix, base, suffix);

            if password.len() >= config.min_length && password.len() <= config.max_length {
                passwords.push(password);
            }
        }

        Ok(passwords)
    }
}
