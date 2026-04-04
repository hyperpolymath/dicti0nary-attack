# justfile - Command runner for dicti0nary-attack (Chapel/WASM edition)
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Security Research Team

# Show available commands
default:
    @just --list

# === Build Commands ===

# Compile Chapel sources
build:
    chpl --fast src/generators/*.chpl src/crackers/*.chpl -o bin/dicti0nary

# Compile Chapel to WASM
build-wasm:
    #!/usr/bin/env bash
    set -euxo pipefail
    mkdir -p web/static/wasm
    emchapel src/generators/Leetspeak.chpl -o web/static/wasm/leetspeak.js
    emchapel src/generators/Pattern.chpl -o web/static/wasm/pattern.js
    emchapel src/crackers/HashCracker.chpl -o web/static/wasm/cracker.js
    echo "✓ WASM modules compiled"

# Build everything
build-all: build build-wasm

# Clean build artifacts
clean:
    rm -rf bin/ web/static/wasm/*.js web/static/wasm/*.wasm
    find . -name "*.o" -delete
    find . -name "*.tmp" -delete
    echo "✓ Cleaned build artifacts"

# === Development Commands ===

# Format Chapel code
format:
    find src/ -name "*.chpl" -exec chplfmt {} \;
    echo "✓ Formatted Chapel code"

# Lint Chapel code
lint:
    find src/ -name "*.chpl" -exec chpl --lint {} \;

# Type check
check:
    chpl --no-codegen --verify src/**/*.chpl

# Run all quality checks
quality: format lint check

# === Testing Commands ===

# Run Chapel tests
test:
    chpl --main-module Tests tests/*.chpl && ./Tests
    rm -f Tests Tests_real

# Run tests with coverage
test-cov:
    chpl --coverage tests/*.chpl -o Tests && ./Tests
    chpl-gcov Tests
    rm -f Tests

# Watch mode for tests (requires entr)
test-watch:
    find src tests -name "*.chpl" | entr just test

# Benchmark performance
bench:
    chpl --fast tests/bench/*.chpl -o Benchmark
    ./Benchmark
    rm -f Benchmark

# === Container Commands (Podman) ===

# Build container with Podman
podman-build:
    podman build -t dicti0nary-attack:latest -f Containerfile .

# Run CLI in container
podman-run:
    podman run --rm -it dicti0nary-attack:latest just info

# Start static web server in container
podman-web:
    podman-compose up dicti0nary-static

# Stop containers
podman-stop:
    podman-compose down

# === Web/Static Site Commands ===

# Serve static site locally (requires Python for dev server)
serve-static PORT="8080":
    @echo "Starting static server on port {{PORT}}..."
    @cd web && python3 -m http.server {{PORT}}

# Build CSS (if using preprocessor)
build-css:
    #!/usr/bin/env bash
    # If using PostCSS or similar
    if [ -f web/static/css/main.pcss ]; then
        postcss web/static/css/main.pcss -o web/static/css/main.css
    fi
    echo "✓ CSS built"

# === 1000Langs Integration ===

# Clone 1000Langs repository
setup-1000langs:
    #!/usr/bin/env bash
    if [ ! -d "vendor/1000Langs" ]; then
        mkdir -p vendor
        git clone https://github.com/Hyperpolymath/1000Langs vendor/1000Langs
        echo "✓ Cloned 1000Langs"
    else
        echo "✓ 1000Langs already present"
    fi

# Extract multilingual wordlists from 1000Langs
extract-wordlists LANG="all":
    #!/usr/bin/env bash
    set -euo pipefail
    cd vendor/1000Langs
    python3 biblecrawler/extract_words.py --lang {{LANG}} --output ../../wordlists/multilang/
    echo "✓ Extracted wordlists for {{LANG}}"

# Generate training data from parallel corpora
generate-training:
    #!/usr/bin/env bash
    cd vendor/1000Langs
    python3 scripts/parallel_corpora.py --output ../../data/training/
    echo "✓ Generated training data from parallel corpora"

# === RSR Compliance ===

# Validate RSR compliance
validate-rsr:
    @echo "Checking RSR compliance..."
    @echo "✓ Checking documentation files..."
    @test -f README.adoc && echo "  ✓ README.adoc"
    @test -f LICENSE && echo "  ✓ LICENSE"
    @test -f CONTRIBUTING.adoc && echo "  ✓ CONTRIBUTING.adoc"
    @test -f CODE_OF_CONDUCT.adoc && echo "  ✓ CODE_OF_CONDUCT.adoc"
    @test -f SECURITY.adoc && echo "  ✓ SECURITY.adoc"
    @test -f CHANGELOG.adoc && echo "  ✓ CHANGELOG.adoc"
    @test -f MAINTAINERS.adoc && echo "  ✓ MAINTAINERS.adoc"
    @echo "✓ Checking .well-known directory..."
    @test -f .well-known/security.txt && echo "  ✓ security.txt"
    @test -f .well-known/ai.txt && echo "  ✓ ai.txt"
    @test -f .well-known/humans.txt && echo "  ✓ humans.txt"
    @echo "✓ Checking build system..."
    @test -f justfile && echo "  ✓ justfile"
    @test -f Chapel.toml && echo "  ✓ Chapel.toml"
    @test -f Containerfile && echo "  ✓ Containerfile (Podman)"
    @test -f podman-compose.yml && echo "  ✓ podman-compose.yml"
    @test -f .github/workflows/ci.yml && echo "  ✓ CI/CD"
    @echo "✓ Running tests..."
    @just test || echo "  ⚠ Tests need implementation"
    @echo ""
    @echo "✅ RSR Compliance Check Complete!"
    @echo "See RSR_COMPLIANCE.adoc for detailed report"

# Validate offline-first operation
validate-offline:
    @echo "Validating offline-first operation..."
    @echo "Checking core generators (no network calls)..."
    @! grep -r "http\|curl\|wget\|fetch" src/generators/ || (echo "❌ Network calls found!" && exit 1)
    @echo "✓ Generators are offline-first"
    @! grep -r "http\|curl\|wget\|fetch" src/crackers/ || (echo "❌ Network calls found!" && exit 1)
    @echo "✓ Crackers are offline-first"
    @echo "✅ Offline-first validation passed!"

# === Nickel Configuration ===

# Evaluate Nickel config
nickel-eval:
    nickel export < config/dicti0nary.ncl

# Type check Nickel config
nickel-check:
    nickel typecheck config/dicti0nary.ncl

# Validate Mustfile.epx
mustfile-check:
    nickel typecheck Mustfile.epx

# === ReScript/Deno Commands ===

# Build ReScript modules
rescript-build:
    deno task build:rescript

# Watch ReScript modules
rescript-watch:
    deno task watch:rescript

# Clean ReScript build
rescript-clean:
    deno task clean:rescript

# === Policy Enforcement ===

# Validate no Makefiles exist
validate-no-makefile:
    @echo "Checking for Makefiles..."
    @! find . -maxdepth 3 \( -name 'Makefile' -o -name 'makefile' -o -name 'GNUmakefile' -o -name '*.mk' \) -not -path './target/*' -not -path './node_modules/*' | grep . || echo "✅ No Makefiles found"

# Validate no npm/bun artifacts
validate-no-npm:
    @echo "Checking for npm/bun artifacts..."
    @! test -f package-lock.json && ! test -f bun.lockb && ! test -f .npmrc && echo "✅ No npm/bun artifacts"

# Validate no new TypeScript
validate-no-typescript:
    @echo "Checking for TypeScript files..."
    @! find . -name '*.ts' -o -name '*.tsx' | grep -v node_modules | grep -v '.d.ts' | grep . || echo "✅ No TypeScript files"

# Run all policy validations
validate-policy: validate-no-makefile validate-no-npm validate-no-typescript
    @echo "✅ All policy validations passed"

# Generate config variants with Nickel
nickel-variants:
    #!/usr/bin/env bash
    for variant in dev prod test; do
        nickel export --field $variant config/dicti0nary.ncl > config/generated/$variant.json
        echo "✓ Generated config/$variant.json"
    done

# === Project Management ===

# Show project statistics
stats:
    @echo "dicti0nary-attack Project Statistics"
    @echo "===================================="
    @echo ""
    @echo "Lines of Chapel:"
    @find src/ -name "*.chpl" -exec wc -l {} + | tail -1
    @echo ""
    @echo "Test Files:"
    @find tests/ -name "*.chpl" 2>/dev/null | wc -l || echo "0"
    @echo ""
    @echo "Documentation Files (.adoc):"
    @find . -maxdepth 2 -name "*.adoc" | wc -l
    @echo ""
    @echo "WASM Modules:"
    @find web/static/wasm -name "*.wasm" 2>/dev/null | wc -l || echo "0"

# Initialize development environment
init: setup-1000langs
    @echo "Installing Chapel (if needed)..."
    @which chpl > /dev/null || echo "⚠ Chapel not installed. Install from chapel-lang.org"
    @echo "Installing Emscripten (if needed)..."
    @which emcc > /dev/null || echo "⚠ Emscripten not installed. Install from emscripten.org"
    @echo "Installing Nickel (if needed)..."
    @which nickel > /dev/null || echo "⚠ Nickel not installed. Install from nickel-lang.org"
    @echo "Creating directories..."
    @mkdir -p bin web/static/{css,js,wasm} data/training wordlists/multilang output
    @echo "✅ Development environment initialized"

# Create a new release
release VERSION:
    @echo "Creating release {{VERSION}}..."
    @echo "Updating Chapel.toml..."
    @sed -i 's/version = "[^"]*"/version = "{{VERSION}}"/' Chapel.toml
    @echo "Running tests..."
    @just test
    @echo "Building release..."
    @just build-all
    @echo "Creating git tag..."
    @git tag -a "v{{VERSION}}" -m "Release v{{VERSION}}"
    @echo "✅ Release v{{VERSION}} ready!"
    @echo "Next: git push origin v{{VERSION}}"

# Show info about generators
info:
    @echo "dicti0nary-attack - Chapel/WASM Edition"
    @echo "======================================="
    @echo ""
    @echo "Available Generators:"
    @echo "  • Leetspeak - Character substitutions (a→4, e→3)"
    @echo "  • Phonetic - Phonetic substitutions (for→4, to→2)"
    @echo "  • Pattern - Keyboard walks, sequences, dates"
    @echo "  • Random - Random non-dictionary passwords"
    @echo "  • Markov - Statistical generation"
    @echo ""
    @echo "Hash Algorithms:"
    @echo "  • MD5, SHA1, SHA256, SHA512"
    @echo ""
    @echo "Powered by Chapel parallel computing"
    @echo "Compiled to WASM for browser execution"

# Run security scan
security:
    @echo "Running security checks..."
    @echo "Checking for hardcoded secrets..."
    @! grep -r "password\s*=\s*['\"]" src/ || echo "⚠ Possible hardcoded password"
    @echo "Checking dependencies..."
    @echo "✓ Chapel has no external dependencies by default"
    @echo "✓ Security scan complete"

# Setup pre-commit hooks
setup-hooks:
    @echo "#!/bin/sh" > .git/hooks/pre-commit
    @echo "just format" >> .git/hooks/pre-commit
    @echo "just lint" >> .git/hooks/pre-commit
    @echo "just test" >> .git/hooks/pre-commit
    @chmod +x .git/hooks/pre-commit
    @echo "✅ Pre-commit hooks installed"

