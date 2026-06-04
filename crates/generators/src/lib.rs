// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//! Password generators for dicti0nary-attack
//!
//! Multiple strategies for generating password candidates.

#![forbid(unsafe_code)]
mod leetspeak;
mod pattern;
mod phonetic;
mod random;

pub use leetspeak::LeetspeakGenerator;
pub use pattern::PatternGenerator;
pub use phonetic::PhoneticGenerator;
pub use random::RandomGenerator;

use dicti0nary_attack_core::{GeneratorConfig, PasswordGenerator, Result};

/// Get all available generators
pub fn all_generators() -> Vec<Box<dyn PasswordGenerator>> {
    vec![
        Box::new(RandomGenerator::new()),
        Box::new(LeetspeakGenerator::new()),
        Box::new(PatternGenerator::new()),
        Box::new(PhoneticGenerator::new()),
    ]
}

/// Combined generator that uses all strategies
pub struct CombinedGenerator {
    generators: Vec<Box<dyn PasswordGenerator>>,
}

impl CombinedGenerator {
    pub fn new() -> Self {
        Self {
            generators: all_generators(),
        }
    }
}

impl Default for CombinedGenerator {
    fn default() -> Self {
        Self::new()
    }
}

impl PasswordGenerator for CombinedGenerator {
    fn name(&self) -> &str {
        "combined"
    }

    fn generate(&self, config: &GeneratorConfig) -> Result<Vec<String>> {
        let mut all_passwords = Vec::new();
        let per_generator = config.count / self.generators.len().max(1);

        let mut adjusted_config = config.clone();
        adjusted_config.count = per_generator;

        for generator in &self.generators {
            match generator.generate(&adjusted_config) {
                Ok(passwords) => all_passwords.extend(passwords),
                Err(e) => {
                    eprintln!("Warning: Generator {} failed: {}", generator.name(), e);
                }
            }
        }

        // Deduplicate
        all_passwords.sort();
        all_passwords.dedup();

        Ok(all_passwords)
    }
}
