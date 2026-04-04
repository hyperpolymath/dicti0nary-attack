//! Core types and traits for dicti0nary-attack
//!
//! This crate provides the foundational types for password generation and hash cracking.

#![forbid(unsafe_code)]
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use thiserror::Error;

/// Errors that can occur during dictionary operations
#[derive(Error, Debug)]
pub enum DictError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Invalid configuration: {0}")]
    Config(String),

    #[error("Hash format not recognized: {0}")]
    UnknownHashFormat(String),

    #[error("Generator error: {0}")]
    Generator(String),

    #[error("Cracker error: {0}")]
    Cracker(String),
}

pub type Result<T> = std::result::Result<T, DictError>;

/// Supported hash types
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum HashType {
    Md5,
    Sha256,
    Sha512,
    Bcrypt,
    Argon2,
}

impl HashType {
    /// Detect hash type from hash string
    pub fn detect(hash: &str) -> Option<Self> {
        match hash.len() {
            32 => Some(Self::Md5),
            64 => Some(Self::Sha256),
            128 => Some(Self::Sha512),
            _ if hash.starts_with("$2") => Some(Self::Bcrypt),
            _ if hash.starts_with("$argon2") => Some(Self::Argon2),
            _ => None,
        }
    }
}

/// Configuration for password generation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GeneratorConfig {
    /// Minimum password length
    pub min_length: usize,
    /// Maximum password length
    pub max_length: usize,
    /// Include numbers
    pub include_numbers: bool,
    /// Include special characters
    pub include_special: bool,
    /// Include uppercase letters
    pub include_uppercase: bool,
    /// Base wordlist path
    pub wordlist: Option<PathBuf>,
    /// Number of passwords to generate
    pub count: usize,
}

impl Default for GeneratorConfig {
    fn default() -> Self {
        Self {
            min_length: 6,
            max_length: 16,
            include_numbers: true,
            include_special: true,
            include_uppercase: true,
            wordlist: None,
            count: 1000,
        }
    }
}

/// Trait for password generators
pub trait PasswordGenerator: Send + Sync {
    /// Generator name
    fn name(&self) -> &str;

    /// Generate passwords
    fn generate(&self, config: &GeneratorConfig) -> Result<Vec<String>>;
}

/// Trait for hash crackers
pub trait HashCracker: Send + Sync {
    /// Cracker name
    fn name(&self) -> &str;

    /// Supported hash types
    fn supported_types(&self) -> Vec<HashType>;

    /// Attempt to crack a hash using the provided wordlist
    fn crack(&self, hash: &str, hash_type: HashType, wordlist: &[String]) -> Result<Option<String>>;
}

/// Result of a cracking attempt
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CrackResult {
    pub hash: String,
    pub hash_type: HashType,
    pub plaintext: Option<String>,
    pub attempts: usize,
    pub duration_ms: u64,
}

/// Statistics from a generation run
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct GenerationStats {
    pub total_generated: usize,
    pub unique_count: usize,
    pub duration_ms: u64,
    pub generator_name: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    // --- HashType tests ---

    #[test]
    fn hash_type_detect_md5_by_length() {
        // MD5 hashes are 32 hex characters
        let hash = "d41d8cd98f00b204e9800998ecf8427e";
        assert_eq!(HashType::detect(hash), Some(HashType::Md5));
    }

    #[test]
    fn hash_type_detect_sha256_by_length() {
        // SHA-256 hashes are 64 hex characters
        let hash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        assert_eq!(HashType::detect(hash), Some(HashType::Sha256));
    }

    #[test]
    fn hash_type_detect_sha512_by_length() {
        // SHA-512 hashes are 128 hex characters
        let hash = "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e";
        assert_eq!(HashType::detect(hash), Some(HashType::Sha512));
    }

    #[test]
    fn hash_type_detect_bcrypt_by_prefix() {
        let hash = "$2b$12$somehashvalue";
        assert_eq!(HashType::detect(hash), Some(HashType::Bcrypt));
    }

    #[test]
    fn hash_type_detect_argon2_by_prefix() {
        let hash = "$argon2id$v=19$m=65536,t=2,p=1$salt$hash";
        assert_eq!(HashType::detect(hash), Some(HashType::Argon2));
    }

    #[test]
    fn hash_type_detect_unknown_returns_none() {
        assert_eq!(HashType::detect("notahash"), None);
        assert_eq!(HashType::detect(""), None);
    }

    // --- GeneratorConfig tests ---

    #[test]
    fn generator_config_default_is_sane() {
        let cfg = GeneratorConfig::default();
        assert!(cfg.min_length > 0, "min_length should be > 0");
        assert!(
            cfg.max_length >= cfg.min_length,
            "max_length must be >= min_length"
        );
        assert!(cfg.count > 0, "count should be > 0");
    }

    #[test]
    fn generator_config_default_includes_numbers() {
        let cfg = GeneratorConfig::default();
        assert!(cfg.include_numbers);
    }

    #[test]
    fn generator_config_default_includes_uppercase() {
        let cfg = GeneratorConfig::default();
        assert!(cfg.include_uppercase);
    }

    // --- GenerationStats tests ---

    #[test]
    fn generation_stats_default_is_zero() {
        let stats = GenerationStats::default();
        assert_eq!(stats.total_generated, 0);
        assert_eq!(stats.unique_count, 0);
        assert_eq!(stats.duration_ms, 0);
        assert!(stats.generator_name.is_empty());
    }

    // --- DictError tests ---

    #[test]
    fn dict_error_config_displays_message() {
        let err = DictError::Config("bad input".to_string());
        let msg = format!("{err}");
        assert!(msg.contains("bad input"), "error message should include the detail");
    }

    #[test]
    fn dict_error_unknown_hash_displays_format() {
        let err = DictError::UnknownHashFormat("xyz".to_string());
        let msg = format!("{err}");
        assert!(msg.contains("xyz"));
    }
}
