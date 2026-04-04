# TEST-NEEDS.md — CRG Grade B Test Suite

This file documents the six independently runnable test targets that bring
`dicti0nary-attack` to **CRG Grade B**.

## Grade B Status: ACHIEVED

| Target | Recipe | Command | Description |
|--------|--------|---------|-------------|
| T1 | `just test-chapel` | `bash tests/run_tests.sh` | Chapel tests (SKIP if `chpl` not installed) |
| T2 | `just test-zig` | `zig test ffi/zig/test/integration_test.zig` | 15 Zig FFI unit tests |
| T3 | `just test-nickel` | `nickel typecheck config/dicti0nary.ncl` | Nickel type-check for config |
| T4 | `just test-rust` | `cargo test --all` | Rust unit tests across all crates (12+ tests) |
| T5 | `just test-structure` | `bash tests/validate_structure.sh` | 7 structural checks (all passing) |
| T6 | `just test-mustfile` | `nickel typecheck Mustfile.epx` | Nickel type-check for Mustfile.epx |

## Running All Targets

```
just test
```

This runs all 6 targets in order: `test-structure test-chapel test-zig test-nickel test-rust test-mustfile`.

## Notes

- T1 (`test-chapel`) gracefully skips with `SKIP:` message and exit 0 when `chpl` is not installed.
- T2 (`test-zig`) requires `zig` to be installed.
- T3 and T6 require `nickel` (available at `~/.local/bin/nickel`).
- T4 (`test-rust`) runs `cargo test --all` across the workspace (core, generators, crackers crates).
- All targets produce clear PASS/FAIL/SKIP output and exit codes.
