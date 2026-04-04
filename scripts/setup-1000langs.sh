#!/usr/bin/env bash
#
# Setup 1000Langs Integration
# Clone and initialize the 1000Langs multilingual corpus repository
#
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Security Research Team

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$PROJECT_ROOT/vendor"
LANGS_DIR="$VENDOR_DIR/1000Langs"

echo "🌍 Setting up 1000Langs multilingual integration..."
echo

# Create vendor directory
mkdir -p "$VENDOR_DIR"

# Clone 1000Langs if not already present
if [ -d "$LANGS_DIR" ]; then
    echo "✓ 1000Langs already present at: $LANGS_DIR"
    echo "  Updating repository..."
    cd "$LANGS_DIR"
    git pull origin main || echo "⚠️  Could not update (offline mode?)"
else
    echo "📥 Cloning 1000Langs repository..."
    git clone https://github.com/Hyperpolymath/1000Langs.git "$LANGS_DIR" \
        || {
            echo "❌ Failed to clone 1000Langs repository"
            echo "   Ensure you have internet connection and git installed"
            exit 1
        }
    echo "✓ Cloned successfully"
fi

cd "$LANGS_DIR"

# Check for required tools
echo
echo "🔧 Checking dependencies..."

check_tool() {
    if command -v "$1" &> /dev/null; then
        echo "  ✓ $1"
    else
        echo "  ✗ $1 (not found)"
        return 1
    fi
}

MISSING_DEPS=0
check_tool "python3" || MISSING_DEPS=1
check_tool "git" || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    echo
    echo "⚠️  Some dependencies are missing. Please install them first."
    exit 1
fi

# Install 1000Langs Python dependencies (if requirements.txt exists)
if [ -f "requirements.txt" ]; then
    echo
    echo "📦 Installing 1000Langs Python dependencies..."
    python3 -m pip install -r requirements.txt --user || {
        echo "⚠️  Could not install Python dependencies"
        echo "   You may need to install them manually"
    }
fi

# Create symlink for easy access
echo
echo "🔗 Creating convenience symlinks..."
ln -sf "$LANGS_DIR" "$PROJECT_ROOT/1000langs" 2>/dev/null || true

# Create wordlists output directory
mkdir -p "$PROJECT_ROOT/wordlists/multilingual"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ 1000Langs setup complete!"
echo
echo "Location:  $LANGS_DIR"
echo "Languages: 1500+ supported"
echo "Corpora:   Bible translations, Wikipedia, Common Crawl"
echo
echo "NEXT STEPS:"
echo "  1. Extract wordlists:  just extract-wordlists LANG"
echo "  2. Generate training:  just generate-training"
echo
echo "EXAMPLES:"
echo "  just extract-wordlists en     # English wordlist"
echo "  just extract-wordlists es     # Spanish wordlist"
echo "  just extract-wordlists zh     # Chinese wordlist"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
