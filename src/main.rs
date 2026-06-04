// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//! dicti0nary-attack CLI
//!
//! Password dictionary generator and hash cracker.

#![forbid(unsafe_code)]
use clap::{Parser, Subcommand};
use dicti0nary_attack_core::{GeneratorConfig, HashType, PasswordGenerator};
use dicti0nary_attack_crackers::MultiHashCracker;
use dicti0nary_attack_generators::CombinedGenerator;
use std::path::PathBuf;
use tracing_subscriber::EnvFilter;

#[derive(Parser)]
#[command(name = "dict0")]
#[command(author = "Jonathan D.A. Jewell")]
#[command(version)]
#[command(about = "Password dictionary generator and hash cracker", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Verbose output
    #[arg(short, long, global = true)]
    verbose: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Generate password candidates
    Generate {
        /// Output file (stdout if not specified)
        #[arg(short, long)]
        output: Option<PathBuf>,

        /// Number of passwords to generate
        #[arg(short, long, default_value = "1000")]
        count: usize,

        /// Minimum password length
        #[arg(long, default_value = "6")]
        min_length: usize,

        /// Maximum password length
        #[arg(long, default_value = "16")]
        max_length: usize,

        /// Generator to use (random, leetspeak, pattern, phonetic, combined)
        #[arg(short, long, default_value = "combined")]
        generator: String,

        /// Base wordlist file
        #[arg(short, long)]
        wordlist: Option<PathBuf>,
    },

    /// Attempt to crack a hash
    Crack {
        /// Hash to crack
        hash: String,

        /// Hash type (md5, sha256, sha512, bcrypt, argon2)
        #[arg(short, long)]
        hash_type: Option<String>,

        /// Wordlist file
        #[arg(short, long)]
        wordlist: PathBuf,
    },

    /// Identify hash type
    Identify {
        /// Hash to identify
        hash: String,
    },

    /// Benchmark generators
    Benchmark {
        /// Number of passwords per generator
        #[arg(short, long, default_value = "10000")]
        count: usize,
    },
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    // Setup logging
    let filter = if cli.verbose {
        EnvFilter::new("debug")
    } else {
        EnvFilter::new("info")
    };
    tracing_subscriber::fmt().with_env_filter(filter).init();

    match cli.command {
        Commands::Generate {
            output,
            count,
            min_length,
            max_length,
            generator: _,
            wordlist,
        } => {
            let config = GeneratorConfig {
                min_length,
                max_length,
                count,
                wordlist,
                ..Default::default()
            };

            let gen = CombinedGenerator::new();
            let passwords = gen.generate(&config)?;

            if let Some(path) = output {
                std::fs::write(&path, passwords.join("\n"))?;
                println!("Generated {} passwords to {}", passwords.len(), path.display());
            } else {
                for pwd in &passwords {
                    println!("{}", pwd);
                }
            }
        }

        Commands::Crack {
            hash,
            hash_type,
            wordlist,
        } => {
            let ht = if let Some(ref t) = hash_type {
                match t.to_lowercase().as_str() {
                    "md5" => HashType::Md5,
                    "sha256" => HashType::Sha256,
                    "sha512" => HashType::Sha512,
                    "bcrypt" => HashType::Bcrypt,
                    "argon2" => HashType::Argon2,
                    _ => return Err(anyhow::anyhow!("Unknown hash type: {}", t)),
                }
            } else {
                HashType::detect(&hash).ok_or_else(|| anyhow::anyhow!("Could not detect hash type"))?
            };

            let words: Vec<String> = std::fs::read_to_string(&wordlist)?
                .lines()
                .map(String::from)
                .collect();

            println!("Attempting to crack {} hash with {} candidates...",
                     format!("{:?}", ht).to_lowercase(), words.len());

            let cracker = MultiHashCracker::new();
            use dicti0nary_attack_core::HashCracker;

            let start = std::time::Instant::now();
            match cracker.crack(&hash, ht, &words)? {
                Some(plaintext) => {
                    println!("✓ Cracked in {:?}: {}", start.elapsed(), plaintext);
                }
                None => {
                    println!("✗ Not found in wordlist ({:?})", start.elapsed());
                }
            }
        }

        Commands::Identify { hash } => {
            match HashType::detect(&hash) {
                Some(ht) => println!("Detected hash type: {:?}", ht),
                None => println!("Could not identify hash type"),
            }
        }

        Commands::Benchmark { count } => {
            use dicti0nary_attack_generators::all_generators;

            let config = GeneratorConfig {
                count,
                ..Default::default()
            };

            println!("Benchmarking generators ({} passwords each)...\n", count);

            for gen in all_generators() {
                let start = std::time::Instant::now();
                let passwords = gen.generate(&config)?;
                let elapsed = start.elapsed();
                let rate = count as f64 / elapsed.as_secs_f64();

                println!(
                    "{:15} {:>8} passwords in {:>8.2?} ({:.0}/sec)",
                    gen.name(),
                    passwords.len(),
                    elapsed,
                    rate
                );
            }
        }
    }

    Ok(())
}
