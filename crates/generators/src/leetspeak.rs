//! Leetspeak password generator
//!
//! Transforms words using common leetspeak substitutions.

use dicti0nary_attack_core::{GeneratorConfig, PasswordGenerator, Result};
use std::collections::HashMap;

/// Generator that applies leetspeak transformations
pub struct LeetspeakGenerator {
    substitutions: HashMap<char, Vec<char>>,
}

impl LeetspeakGenerator {
    pub fn new() -> Self {
        let mut subs = HashMap::new();
        subs.insert('a', vec!['4', '@']);
        subs.insert('b', vec!['8']);
        subs.insert('e', vec!['3']);
        subs.insert('g', vec!['9', '6']);
        subs.insert('i', vec!['1', '!']);
        subs.insert('l', vec!['1', '|']);
        subs.insert('o', vec!['0']);
        subs.insert('s', vec!['5', '$']);
        subs.insert('t', vec!['7', '+']);
        subs.insert('z', vec!['2']);

        Self { substitutions: subs }
    }

    fn transform(&self, word: &str) -> Vec<String> {
        let mut results = vec![word.to_string()];

        for (original, replacements) in &self.substitutions {
            let mut new_results = Vec::new();
            for result in &results {
                for replacement in replacements {
                    let transformed = result.replace(*original, &replacement.to_string());
                    if transformed != *result {
                        new_results.push(transformed);
                    }
                }
            }
            results.extend(new_results);
        }

        results
    }
}

impl Default for LeetspeakGenerator {
    fn default() -> Self {
        Self::new()
    }
}

impl PasswordGenerator for LeetspeakGenerator {
    fn name(&self) -> &str {
        "leetspeak"
    }

    fn generate(&self, config: &GeneratorConfig) -> Result<Vec<String>> {
        let base_words: Vec<String> = if let Some(ref path) = config.wordlist {
            std::fs::read_to_string(path)?
                .lines()
                .map(String::from)
                .collect()
        } else {
            // Default common words
            vec![
                "password", "admin", "user", "login", "welcome",
                "hello", "secret", "dragon", "master", "monkey",
            ]
            .into_iter()
            .map(String::from)
            .collect()
        };

        let mut passwords = Vec::new();
        for word in base_words {
            let lower: String = word.to_lowercase();
            let transformed = self.transform(&lower);
            passwords.extend(transformed);

            if passwords.len() >= config.count {
                break;
            }
        }

        passwords.truncate(config.count);
        Ok(passwords)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_leetspeak_transform() {
        let gen = LeetspeakGenerator::new();
        let results = gen.transform("password");
        assert!(results.contains(&"p4ssword".to_string()));
        assert!(results.contains(&"passw0rd".to_string()));
    }
}
