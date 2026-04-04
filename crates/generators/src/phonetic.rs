//! Phonetic password generator
//!
//! Generates pronounceable passwords using syllable patterns.

use dicti0nary_attack_core::{GeneratorConfig, PasswordGenerator, Result};
use rand::Rng;

/// Generator that creates pronounceable passwords
pub struct PhoneticGenerator {
    consonants: Vec<&'static str>,
    vowels: Vec<&'static str>,
}

impl PhoneticGenerator {
    pub fn new() -> Self {
        Self {
            consonants: vec![
                "b", "c", "d", "f", "g", "h", "j", "k", "l", "m",
                "n", "p", "r", "s", "t", "v", "w", "z", "ch", "sh",
                "th", "ph", "br", "cr", "dr", "fr", "gr", "pr", "tr",
            ],
            vowels: vec![
                "a", "e", "i", "o", "u", "ai", "ea", "ee", "ie", "oo",
                "ou", "oi",
            ],
        }
    }

    fn generate_syllable(&self, rng: &mut impl Rng) -> String {
        let c1 = self.consonants[rng.gen_range(0..self.consonants.len())];
        let v = self.vowels[rng.gen_range(0..self.vowels.len())];
        let c2 = self.consonants[rng.gen_range(0..self.consonants.len())];

        match rng.gen_range(0..3) {
            0 => format!("{}{}", c1, v),
            1 => format!("{}{}", v, c2),
            _ => format!("{}{}{}", c1, v, c2),
        }
    }
}

impl Default for PhoneticGenerator {
    fn default() -> Self {
        Self::new()
    }
}

impl PasswordGenerator for PhoneticGenerator {
    fn name(&self) -> &str {
        "phonetic"
    }

    fn generate(&self, config: &GeneratorConfig) -> Result<Vec<String>> {
        let mut rng = rand::thread_rng();
        let mut passwords = Vec::new();

        for _ in 0..config.count {
            let mut password = String::new();
            while password.len() < config.min_length {
                password.push_str(&self.generate_syllable(&mut rng));
            }

            // Truncate if too long
            if password.len() > config.max_length {
                password.truncate(config.max_length);
            }

            // Optionally add numbers
            if config.include_numbers && rng.gen_bool(0.5) {
                password.push_str(&rng.gen_range(0..100).to_string());
            }

            passwords.push(password);
        }

        Ok(passwords)
    }
}
