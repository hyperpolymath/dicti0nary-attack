# Repository Configuration

This file documents the expected GitHub repository settings for `dicti0nary-attack`.

## Description

```
Non-dictionary password research tool - Chapel/WASM + Rust CLI for generating and testing password variations
```

## Topics (Tags)

The repository should have the following topics:

### Primary (Required)
- `security`
- `password`
- `security-research`
- `chapel`
- `rust`
- `wasm`
- `offline-first`

### Secondary (Recommended)
- `rescript`
- `password-cracking`
- `hash-cracking`
- `cryptography`
- `ctf-tools`
- `security-tools`
- `parallel-computing`
- `webassembly`

### Framework Tags
- `rsr-framework` (Responsible Research Framework compliance)
- `nickel-lang` (Configuration)
- `deno` (JavaScript runtime)

## Setting Topics via GitHub CLI

```bash
gh repo edit hyperpolymath/dicti0nary-attack \
  --description "Non-dictionary password research tool - Chapel/WASM + Rust CLI for generating and testing password variations" \
  --add-topic security \
  --add-topic password \
  --add-topic security-research \
  --add-topic chapel \
  --add-topic rust \
  --add-topic wasm \
  --add-topic offline-first \
  --add-topic rescript \
  --add-topic password-cracking \
  --add-topic cryptography \
  --add-topic ctf-tools \
  --add-topic parallel-computing
```

## Language Policy Compliance

This repository follows the Hyperpolymath Language Policy:

| Allowed | Use Case |
|---------|----------|
| Chapel | Primary password generation/cracking |
| Rust | CLI implementation |
| ReScript | Web interface logic |
| Nickel | Configuration |
| Bash | Scripts/automation |

| Banned | Replacement |
|--------|-------------|
| TypeScript | ReScript |
| Python | Chapel/Rust |
| Node.js | Deno |
| npm/bun | Deno |
| Makefile | justfile |

## Verification

After setting topics, verify with:

```bash
gh repo view hyperpolymath/dicti0nary-attack --json repositoryTopics,description
```
