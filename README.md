<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

[![License: MPL-2.0](https://img.shields.io/badge/License-MPL_2.0--1.0-blue.svg)](https://github.com/hyperpolymath/palimpsest-license)

\> A comprehensive security research utility for testing non-dictionary
passwords

Everyone knows that it’s easy to crack a password if it appears in a
dictionary. *dicti0nary-attack* is a humorous inversion of that
concept - it’s a powerful tool for generating and testing passwords that
are NOT in traditional dictionaries, focusing on the creative variations
users think make their passwords "secure."

[![License: MPL-2.0](https://img.shields.io/badge/License-MPL_2.0--1.0-blue.svg)](https://github.com/hyperpolymath/palimpsest-license)
link:[\![Chapel](https://img.shields.io/badge/Chapel-2.3+-purple.svg)\](<https://chapel-lang.org/>)
[\![Rust](https://img.shields.io/badge/Rust-2021-orange.svg)\](<https://www.rust-lang.org/>)
link:[\![ReScript](https://img.shields.io/badge/ReScript-11+-red.svg)\](<https://rescript-lang.org/>)
[\![RSR
Compliance](https://img.shields.io/badge/RSR-Bronze%20(86%25)-yellow.svg)\](RSR_COMPLIANCE.md)
[\![Offline-First](https://img.shields.io/badge/offline--first-100%25-green.svg)\](RSR_COMPLIANCE.md#5-offline-first—​compliant)

# ⚠️ Legal Notice

*This tool is for authorized security testing only.*

Authorized use includes: - ✅ Penetration testing with explicit written
permission - ✅ Security audits of systems you own - ✅ CTF (Capture The
Flag) competitions - ✅ Academic research and education - ✅ Password
strength analysis on your own data

Unauthorized access to computer systems is *illegal* and may result in
criminal prosecution under computer fraud and abuse laws.

# ✨ Features

## Password Generators

- *Leetspeak Generator*: Transforms words using character substitutions
  (a→4, e→3, o→0, etc.)

- *Phonetic Generator*: Uses phonetic substitutions (for→4, to→2, you→u)

- *Pattern Generator*: Creates pattern-based passwords (keyboard walks,
  sequences, date patterns)

- *Random Generator*: Generates truly random non-dictionary passwords

- *Markov Chain Generator*: Statistical password generation based on
  training data

## Hash Cracking

- *Multi-Algorithm Support*: MD5, SHA1, SHA224, SHA256, SHA384, SHA512,
  BLAKE2b, BLAKE2s

- *Parallel Processing*: Multi-core support for faster cracking

- *Batch Operations*: Crack multiple hashes simultaneously

- *Progress Tracking*: Real-time statistics and progress monitoring

## Additional Features

- 🎨 *Rich CLI Interface*: Beautiful terminal UI with progress bars and
  tables

- 🌐 *Web Interface*: Browser-based GUI for easy password generation and
  cracking

- 📊 *Comprehensive Statistics*: Detailed performance metrics and
  reporting

- 🔧 *Flexible Configuration*: YAML/JSON configuration files

- 📝 *Multiple Output Formats*: Text, JSON, CSV, HTML reports

- 🐳 *Docker Support*: Containerized deployment

- 🧪 *Extensive Test Suite*: High code coverage with pytest

- ⚡ *Performance Benchmarks*: Built-in benchmarking tools

- 🏆 *RSR Framework Compliant*: Bronze level (86% compliance)

- 📴 *Offline-First*: Core functionality works without internet

- 🔒 *Security-First*: RFC 9116 compliant, comprehensive security policy

# 📦 Installation

## Prerequisites

- **Chapel** 2.3+ - [Download
  Chapel](https://chapel-lang.org/download.html)

- **Rust** 2021 edition - [Install via rustup](https://rustup.rs/)

- **Deno** (for web dev) - [Install Deno](https://deno.land/)

- **just** task runner - [Install just](https://just.systems/)

## From Source

```bash
git clone https://github.com/Hyperpolymath/dicti0nary-attack.git
cd dicti0nary-attack

# Initialize development environment
just init

# Build Chapel + Rust CLI
just build

# Build WASM for web interface
just build-wasm
```

## Using Podman/Docker

```bash
# Build with Podman (preferred)
podman build -t dicti0nary-attack -f Containerfile .
podman run --rm dicti0nary-attack just info

# Or with Docker
docker build -t dicti0nary-attack .
docker run --rm dicti0nary-attack just info
```

## Using Podman Compose

```bash
# Run CLI
podman-compose run dicti0nary-cli just info

# Run web interface (static server)
podman-compose up dicti0nary-static
```

# 🚀 Quick Start

## Generate Passwords

```bash
# Generate 1000 leetspeak passwords
dicti0nary generate -g leetspeak -n 1000

# Save to file
dicti0nary generate -g pattern -n 5000 -o passwords.txt

# Custom length constraints
dicti0nary generate -g random -n 100 --min-length 12 --max-length 20
```

## Crack Password Hashes

```bash
# Crack a SHA256 hash using pattern generator
dicti0nary crack 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8 -a sha256 -g pattern

# Use parallel processing
dicti0nary crack <hash> -a sha256 -g leetspeak -p --workers 8

# Use custom wordlist
dicti0nary crack <hash> -a md5 -w wordlists/custom.txt
```

## Create Wordlists

```bash
# Create leetspeak wordlist
dicti0nary create-wordlist wordlists/leetspeak.txt -g leetspeak -n 50000

# Create phonetic wordlist
dicti0nary create-wordlist wordlists/phonetic.txt -g phonetic -n 10000
```

## Hash Passwords

```bash
# Hash with SHA256
dicti0nary hash-password "mypassword"

# Hash with MD5
dicti0nary hash-password "mypassword" -a md5
```

## Run Web Interface

```bash
# Serve static web interface
just serve-static

# Or with Deno
deno task serve
```

Visit <http://localhost:8080> in your browser.

# 📚 Documentation

- [Usage Guide](docs/USAGE.md) - Comprehensive usage instructions

- [API Documentation](docs/API.md) - Python API reference

- [Plugin Guide](docs/PLUGINS.md) - Plugin development guide

- [Configuration Guide](config/README.md) - Configuration options

- [RSR Compliance](RSR_COMPLIANCE.md) - Standards compliance report

- [Security Policy](SECURITY.md) - Vulnerability reporting

- [Contributing](CONTRIBUTING.md) - Contribution guidelines

# 🎯 Use Cases

## Security Audit

Test if users are using common non-dictionary password patterns:

```bash
dicti0nary create-wordlist audit.txt -g leetspeak -n 100000
dicti0nary crack <hash> -w audit.txt -a sha256
```

## CTF Competition

Quickly test common patterns:

```bash
dicti0nary crack <ctf_hash> -a md5 -g pattern -p
```

## Password Research

Generate datasets for password strength analysis:

```bash
dicti0nary create-wordlist data/leetspeak.txt -g leetspeak -n 50000
dicti0nary create-wordlist data/phonetic.txt -g phonetic -n 50000
dicti0nary create-wordlist data/patterns.txt -g pattern -n 50000
```

# 🏗️ Architecture

```text
dicti0nary-attack/
├── src/                          # Main source code
│   ├── main.rs                   # Rust CLI entry point
│   ├── dicti0nary.chpl           # Chapel main program
│   ├── generators/               # Chapel generator modules
│   │   ├── Leetspeak.chpl        # Leetspeak transformations
│   │   ├── Phonetic.chpl         # Phonetic substitutions
│   │   ├── Pattern.chpl          # Pattern-based generation
│   │   ├── Random.chpl           # Random generation
│   │   └── Markov.chpl           # Markov chain generation
│   └── crackers/                 # Hash cracking engine
│       └── HashCracker.chpl      # Multi-algorithm cracker
├── crates/                       # Rust workspace crates
│   ├── core/                     # Type definitions & traits
│   ├── generators/               # Rust generator implementations
│   └── crackers/                 # Rust cracking engine
├── web/                          # Static web interface
│   ├── index.html                # Main HTML
│   ├── src/                      # ReScript source
│   │   ├── App.res               # Application logic
│   │   ├── Generators.res        # Password generators
│   │   ├── Hash.res              # Hashing utilities
│   │   └── WasmLoader.res        # WASM module loader
│   └── static/                   # Static assets
│       ├── css/                  # CSS-first styling
│       ├── js/                   # Compiled ReScript output
│       └── wasm/                 # Chapel-compiled WASM
├── config/                       # Configuration files
│   ├── dicti0nary.ncl            # Nickel configuration
│   └── *.yaml                    # YAML configs
├── tests/                        # Chapel test suite
├── docs/                         # Documentation
├── wordlists/                    # Example wordlists
├── Justfile                      # Task automation
├── Cargo.toml                    # Rust workspace manifest
├── Chapel.toml                   # Chapel config
├── rescript.json                 # ReScript config
└── deno.json                     # Deno config
```

# 🔧 Configuration

Create a configuration file (`config.yaml`):

```yaml
generators:
  leetspeak:
    max_substitutions: 3
    min_length: 6
    max_length: 16

  pattern:
    min_length: 6
    max_length: 16

cracker:
  algorithm: sha256
  workers: 8
  batch_size: 5000

output:
  format: json
  directory: output
  save_stats: true
```

Use with commands:

```bash
dicti0nary --config config.yaml generate -g leetspeak -n 1000
```

# 🧪 Testing

Run the test suite:

```bash
# Run Chapel tests
just test

# Run with coverage
just test-cov

# Run Rust tests
cargo test

# Watch mode (requires entr)
just test-watch
```

# 📊 Benchmarks

Run performance benchmarks:

```bash
# Run Chapel benchmarks
just bench

# Run Rust benchmarks
cargo bench
```

# 🐳 Container Usage

## Build Image (Podman preferred)

```bash
# Podman (preferred)
podman build -t dicti0nary-attack -f Containerfile .

# Docker
docker build -t dicti0nary-attack .
```

## Run CLI

```bash
podman run --rm dicti0nary-attack just info
```

## Run Web Interface

```bash
podman-compose up dicti0nary-static
```

Access at <http://localhost:8080>

# 🛠️ Development

## Setup Development Environment

```bash
# Clone repository
git clone https://github.com/Hyperpolymath/dicti0nary-attack.git
cd dicti0nary-attack

# Initialize (installs deps, sets up directories)
just init

# Install pre-commit hooks
just setup-hooks

# Build ReScript (web interface)
deno task build:rescript

# Watch mode for development
deno task watch:rescript
```

## Available just Commands

```bash
just               # List all commands
just build         # Compile Chapel sources
just build-wasm    # Compile to WASM
just build-all     # Build everything
just test          # Run Chapel tests
just test-cov      # Tests with coverage
just bench         # Performance benchmarks
just format        # Format Chapel code
just lint          # Lint Chapel code
just quality       # All quality checks
just clean         # Remove build artifacts
just serve-static  # Serve web interface
just podman-build  # Build container
just validate-rsr  # Check RSR compliance
just nickel-eval   # Evaluate Nickel config
just stats         # Show project statistics
```

# 🤝 Contributing

Contributions are welcome! Please ensure:

1.  All tests pass: `just` `test` and `cargo` `test`

2.  Code is formatted: `just` `format` and `cargo` `fmt`

3.  No linting errors: `just` `lint` and `cargo` `clippy`

4.  ReScript compiles: `deno` `task` `build:rescript`

5.  Documentation is updated

# 📄 License

This project is licensed under the GNU General Public License v3.0 - see
the [LICENSE](LICENSE) file for details.

# 🙏 Acknowledgments

- Inspired by the need for better password security testing tools

- Built with Chapel, Rust, ReScript, and Nickel

- Powered by WASM for offline-first browser execution

- Thanks to the security research community

# 📞 Contact & Support

- *Issues*: [GitHub
  Issues](https://github.com/Hyperpolymath/dicti0nary-attack/issues)

- *Documentation*: [docs/](docs/)

- *License*: GPL-3.0

# 🔒 Security Notice

This tool is designed to help security professionals identify weak
passwords. It should never be used:

- To gain unauthorized access to any system

- To crack passwords you don’t have permission to test

- For any illegal or unethical purposes

Always obtain explicit written permission before testing any system you
do not own.

------------------------------------------------------------------------

*Made with ❤️ for the security research community*
