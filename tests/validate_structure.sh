#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Structural validation for dicti0nary-attack (CRG Grade B)
# Checks that all required RSR files and directories are present.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

# Required documentation files
[ -f README.adoc ] && pass "README.adoc present" || fail "README.adoc missing"
[ -f LICENSE ] && pass "LICENSE present" || fail "LICENSE missing"
[ -f SECURITY.md ] && pass "SECURITY.md present" || fail "SECURITY.md missing"
[ -f ABI-FFI-README.md ] && pass "ABI-FFI-README.md present" || fail "ABI-FFI-README.md missing"

# Polyglot build manifests
[ -f Chapel.toml ] && pass "Chapel.toml present" || fail "Chapel.toml missing"
[ -f Cargo.toml ] && pass "Cargo.toml present" || fail "Cargo.toml missing"

# Workflows — must have at least 3
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" 2>/dev/null | wc -l)
if [ "$WORKFLOW_COUNT" -ge 3 ]; then
  pass ".github/workflows has $WORKFLOW_COUNT workflow files (>= 3)"
else
  fail ".github/workflows has only $WORKFLOW_COUNT workflow files (need >= 3)"
fi

# Summary
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
