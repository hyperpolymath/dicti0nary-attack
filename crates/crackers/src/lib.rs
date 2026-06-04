// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//! Hash crackers for dicti0nary-attack
//!
//! Multiple hash type support with parallel cracking.

#![forbid(unsafe_code)]
use dicti0nary_attack_core::{HashCracker, HashType, Result};
use md5::{Digest as Md5Digest, Md5};
use rayon::prelude::*;
use sha2::{Sha256, Sha512};

/// Multi-hash cracker supporting common hash types
pub struct MultiHashCracker;

impl MultiHashCracker {
    pub fn new() -> Self {
        Self
    }

    fn hash_md5(input: &str) -> String {
        let mut hasher = Md5::new();
        hasher.update(input.as_bytes());
        format!("{:x}", hasher.finalize())
    }

    fn hash_sha256(input: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(input.as_bytes());
        format!("{:x}", hasher.finalize())
    }

    fn hash_sha512(input: &str) -> String {
        let mut hasher = Sha512::new();
        hasher.update(input.as_bytes());
        format!("{:x}", hasher.finalize())
    }

    fn verify_bcrypt(input: &str, hash: &str) -> bool {
        bcrypt::verify(input, hash).unwrap_or(false)
    }

    fn verify_argon2(input: &str, hash: &str) -> bool {
        use argon2::{Argon2, PasswordHash, PasswordVerifier};
        PasswordHash::new(hash)
            .ok()
            .and_then(|parsed| Argon2::default().verify_password(input.as_bytes(), &parsed).ok())
            .is_some()
    }
}

impl Default for MultiHashCracker {
    fn default() -> Self {
        Self::new()
    }
}

impl HashCracker for MultiHashCracker {
    fn name(&self) -> &str {
        "multi-hash"
    }

    fn supported_types(&self) -> Vec<HashType> {
        vec![
            HashType::Md5,
            HashType::Sha256,
            HashType::Sha512,
            HashType::Bcrypt,
            HashType::Argon2,
        ]
    }

    fn crack(
        &self,
        hash: &str,
        hash_type: HashType,
        wordlist: &[String],
    ) -> Result<Option<String>> {
        let target_hash = hash.to_lowercase();

        // Use parallel iteration for speed
        let result = wordlist.par_iter().find_any(|word| {
            match hash_type {
                HashType::Md5 => Self::hash_md5(word) == target_hash,
                HashType::Sha256 => Self::hash_sha256(word) == target_hash,
                HashType::Sha512 => Self::hash_sha512(word) == target_hash,
                HashType::Bcrypt => Self::verify_bcrypt(word, hash),
                HashType::Argon2 => Self::verify_argon2(word, hash),
            }
        });

        Ok(result.cloned())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_md5_crack() {
        let cracker = MultiHashCracker::new();
        let wordlist = vec!["password".to_string(), "admin".to_string()];

        // MD5 of "password" is 5f4dcc3b5aa765d61d8327deb882cf99
        let result = cracker
            .crack(
                "5f4dcc3b5aa765d61d8327deb882cf99",
                HashType::Md5,
                &wordlist,
            )
            .unwrap();

        assert_eq!(result, Some("password".to_string()));
    }

    #[test]
    fn test_sha256_hash() {
        let hash = MultiHashCracker::hash_sha256("password");
        // SHA256 of "password" - verify length is correct
        assert_eq!(hash.len(), 64);
        assert_eq!(
            hash,
            "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
        );
    }
}
