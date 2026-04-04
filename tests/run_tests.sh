#!/usr/bin/env bash
#
# Run Chapel Test Suite
#
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Security Research Team

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "═══════════════════════════════════════════════════════════════"
echo "  dicti0nary-attack Chapel Test Suite"
echo "═══════════════════════════════════════════════════════════════"
echo

# Check for Chapel compiler
if ! command -v chpl &> /dev/null; then
    echo "❌ Chapel compiler (chpl) not found"
    echo "   Please install Chapel: https://chapel-lang.org"
    exit 1
fi

echo "✓ Chapel compiler found: $(chpl --version | head -n1)"
echo

# Find all test files
TEST_FILES=($(find "$SCRIPT_DIR" -name "test_*.chpl" | sort))

if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo "⚠️  No test files found"
    exit 0
fi

echo "Found ${#TEST_FILES[@]} test file(s)"
echo

PASSED=0
FAILED=0
FAILED_TESTS=()

# Run each test
for test_file in "${TEST_FILES[@]}"; do
    test_name=$(basename "$test_file" .chpl)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Compile test
    test_exe="$SCRIPT_DIR/$test_name"

    if chpl -o "$test_exe" "$test_file" -M "$PROJECT_ROOT/src/generators" 2>&1; then
        echo "  ✓ Compiled successfully"
        echo

        # Run test
        if "$test_exe"; then
            echo
            echo "  ✓ $test_name PASSED"
            ((PASSED++))
        else
            echo
            echo "  ✗ $test_name FAILED"
            ((FAILED++))
            FAILED_TESTS+=("$test_name")
        fi

        # Clean up executable
        rm -f "$test_exe" "${test_exe}_real"
    else
        echo
        echo "  ✗ $test_name COMPILATION FAILED"
        ((FAILED++))
        FAILED_TESTS+=("$test_name (compilation)")
    fi

    echo
done

echo "═══════════════════════════════════════════════════════════════"
echo "  Test Results"
echo "═══════════════════════════════════════════════════════════════"
echo
echo "  Total tests:  $((PASSED + FAILED))"
echo "  Passed:       $PASSED"
echo "  Failed:       $FAILED"
echo

if [ $FAILED -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed:"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo "    • $failed_test"
    done
    exit 1
fi
