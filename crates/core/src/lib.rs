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
