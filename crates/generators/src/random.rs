//! Random password generator

use dicti0nary_attack_core::{GeneratorConfig, PasswordGenerator, Result};
use rand::Rng;

/// Generator that creates random passwords
pub struct RandomGenerator;

impl RandomGenerator {
    pub fn new() -> Self {
        Self
    }

    fn generate_one(&self, config: &GeneratorConfig) -> String {
        let mut rng = rand::thread_rng();
        let length = rng.gen_range(config.min_length..=config.max_length);

        let mut charset: Vec<char> = ('a'..='z').collect();

        if config.include_uppercase {
            charset.extend('A'..='Z');
        }
        if config.include_numbers {
            charset.extend('0'..='9');
        }
        if config.include_special {
            charset.extend("!@#$%^&*()_+-=[]{}|;:,.<>?".chars());
        }

        (0..length)
            .map(|_| charset[rng.gen_range(0..charset.len())])
            .collect()
    }
}

impl Default for RandomGenerator {
    fn default() -> Self {
        Self::new()
    }
}

impl PasswordGenerator for RandomGenerator {
    fn name(&self) -> &str {
        "random"
    }

    fn generate(&self, config: &GeneratorConfig) -> Result<Vec<String>> {
        let passwords: Vec<String> = (0..config.count)
            .map(|_| self.generate_one(config))
            .collect();
        Ok(passwords)
    }
}
