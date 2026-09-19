<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

# Contributing to dicti0nary-attack

Thank you for your interest in contributing to dicti0nary-attack! This
document provides guidelines for contributing to the project.

## Code of Conduct

This project adheres to a code of conduct that promotes: - Respectful
and inclusive communication - Ethical use of security tools -
Collaboration and constructive feedback

## How to Contribute

### Reporting Bugs

If you find a bug:

1.  Check if the issue already exists in [GitHub
    Issues](https://github.com/Hyperpolymath/dicti0nary-attack/issues)

2.  If not, create a new issue with:

    - Clear, descriptive title

    - Steps to reproduce

    - Expected vs actual behavior

    - Environment details (OS, Python version, etc.)

    - Code samples or error messages

### Suggesting Features

Feature requests are welcome! Please:

1.  Check existing issues and discussions

2.  Create a new issue with:

    - Clear description of the feature

    - Use cases and benefits

    - Potential implementation approach

    - Examples if applicable

### Pull Requests

We love pull requests! Here’s the process:

1.  *Fork the repository*

2.  *Create a feature branch* `` `bash `` `git` `checkout` `-b`
    `feature/your-feature-name`\`

<!-- -->

3.  *Make your changes*

    - Write clean, readable code

    - Follow existing code style

    - Add tests for new functionality

    - Update documentation

<!-- -->

4.  *Test your changes* \`\`\`bash # Run tests pytest

<!-- -->

    # Check coverage
    pytest --cov=dicti0nary_attack

    # Run linters
    flake8 src/ tests/
    ```

5.  *Commit your changes* `` `bash `` `git` `commit` `-m` `"Add`
    `feature:` `description` `of` `your` `changes"`\`

<!-- -->

6.  *Push to your fork* `` `bash `` `git` `push` `origin`
    `feature/your-feature-name`\`

<!-- -->

7.  *Open a Pull Request*

    - Provide a clear description

    - Reference any related issues

    - Explain the changes made

    - Include screenshots if applicable

## Development Setup

``` bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/dicti0nary-attack.git
cd dicti0nary-attack

# Install in development mode
pip install -e .

# Install development dependencies
pip install pytest pytest-cov flake8 black isort

# Run tests
pytest
```

## Code Style

We follow PEP 8 with some modifications:

- *Line Length*: 127 characters max (relaxed from 79)

- *Formatting*: Use `black` for automatic formatting

- *Imports*: Use `isort` to organize imports

- *Docstrings*: Google-style docstrings

Format your code:

``` bash
# Auto-format with black
black src/ tests/

# Sort imports
isort src/ tests/

# Check with flake8
flake8 src/ tests/
```

## Testing Guidelines

All new features must include tests:

- *Unit Tests*: Test individual functions and classes

- *Integration Tests*: Test component interactions

- *Coverage*: Aim for \>80% code coverage

Test file structure:

``` python
"""Tests for module_name."""

import pytest
from dicti0nary_attack.module import ClassName


class TestClassName:
    """Tests for ClassName."""

    def test_feature_description(self):
        """Test that feature works correctly."""
        # Arrange
        instance = ClassName()

        # Act
        result = instance.method()

        # Assert
        assert result == expected_value
```

## Documentation

Update documentation for:

- New features

- API changes

- Configuration options

- Usage examples

Documentation locations: - `README.md` - Overview and quick start -
`docs/USAGE.md` - Detailed usage guide - `docs/API.md` - API reference -
Code docstrings - Inline documentation

## Adding New Generators

To add a new password generator:

1.  *Create generator file*:
    `src/dicti0nary_attack/generators/your_generator.py`

``` python
from dicti0nary_attack.generators.base import PasswordGenerator
from typing import Iterator, Optional

class YourGenerator(PasswordGenerator):
    def generate(self, count: Optional[int] = None) -> Iterator[str]:
        # Your implementation
        pass
```

2.  *Add toinit.py*: `src/dicti0nary_attack/generators/`*`init`*`.py`

<!-- -->

3.  *Write tests*: `tests/test_your_generator.py`

<!-- -->

4.  *Update CLI*: Add to `src/dicti0nary_attack/cli.py`

<!-- -->

5.  *Update documentation*

## Adding New Features

For substantial features:

1.  *Discuss first*: Open an issue to discuss the feature

2.  *Plan the implementation*: Outline your approach

3.  *Break into commits*: Make logical, atomic commits

4.  *Test thoroughly*: Include comprehensive tests

5.  *Document completely*: Update all relevant docs

## Commit Message Guidelines

Use clear, descriptive commit messages:

``` text
Add feature: brief description

Detailed explanation of what changed and why.
Include any relevant context or breaking changes.

Closes #123
```

Format: - *Add*: New features - *Fix*: Bug fixes - *Update*: Changes to
existing features - *Refactor*: Code improvements without functional
changes - *Docs*: Documentation updates - *Test*: Test additions or
changes

## Review Process

All pull requests go through review:

1.  Automated tests must pass

2.  Code review by maintainers

3.  Discussion and potential revisions

4.  Approval and merge

## Security Considerations

When contributing:

- *Never commit secrets*: No API keys, passwords, etc.

- *Validate inputs*: Always validate and sanitize user input

- *Document security implications*: Explain security-related changes

- *Report vulnerabilities*: Email security issues privately

## License

By contributing, you agree that your contributions will be licensed
under the GPL-3.0 License.

## Questions?

- Open an issue for questions

- Check existing documentation

- Review closed issues and PRs

Thank you for contributing to dicti0nary-attack! 🎉

## Local environment setup

_Carried over from the former root `CONTRIBUTING.md` when the guide moved to `.github/`, so nothing is lost: the setup steps this repository had at the root._

<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
git clone https://github.com/hyperpolymath/dicti0nary-attack.git
cd dicti0nary-attack

# Using Guix (recommended for reproducibility)
guix develop

# Or using toolbox/distrobox
toolbox create dicti0nary-attack-dev
toolbox enter dicti0nary-attack-dev
# Install dependencies manually

# Verify setup
just check   # or: cargo check / mix compile / etc.
just test    # Run test suite
```

### Repository Structure

```text
dicti0nary-attack/
├── src/ # Source code (Perimeter 1-2)
├── lib/ # Library code (Perimeter 1-2)
├── extensions/ # Extensions (Perimeter 2)
├── plugins/ # Plugins (Perimeter 2)
├── tools/ # Tooling (Perimeter 2)
├── docs/ # Documentation (Perimeter 3)
│   ├── architecture/ # ADRs, specs (Perimeter 2)
│   └── proposals/ # RFCs (Perimeter 3)
├── examples/ # Examples (Perimeter 3)
├── spec/ # Spec tests (Perimeter 3)
├── tests/ # Test suite (Perimeter 2-3)
├── .well-known/ # Protocol files (Perimeter 1-3)
├── .github/ # GitHub config (Perimeter 1)
│   ├── CONTRIBUTING.md # This file
│   ├── ISSUE_TEMPLATE/
│   └── workflows/
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── GOVERNANCE.md
├── LICENSE
├── MAINTAINERS.md
├── README.adoc
├── SECURITY.md
├── flake.guix # Guix flake (Perimeter 1)
└── Justfile # Task runner (Perimeter 1)
```

---

## How to Contribute

### Reporting Bugs

**Before reporting**:
1. Search existing issues
2. Check if it's already fixed in `main`
3. Determine which perimeter the bug affects

**When reporting**:

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) and include:

- Clear, descriptive title
- Environment details (OS, versions, toolchain)
- Steps to reproduce
- Expected vs actual behaviour
- Logs, screenshots, or minimal reproduction

### Suggesting Features

**Before suggesting**:
1. Check the [roadmap](ROADMAP.md) if available
2. Search existing issues and discussions
3. Consider which perimeter the feature belongs to

**When suggesting**:

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) and include:

- Problem statement (what pain point does this solve?)
- Proposed solution
- Alternatives considered
- Which perimeter this affects

### Your First Contribution

Look for issues labelled:

- [`good first issue`](https://github.com/hyperpolymath/dicti0nary-attack/labels/good%20first%20issue) — Simple Perimeter 3 tasks
- [`help wanted`](https://github.com/hyperpolymath/dicti0nary-attack/labels/help%20wanted) — Community help needed
- [`documentation`](https://github.com/hyperpolymath/dicti0nary-attack/labels/documentation) — Docs improvements
- [`perimeter-3`](https://github.com/hyperpolymath/dicti0nary-attack/labels/perimeter-3) — Community sandbox scope

---

## Development Workflow

### Branch Naming
```
docs/short-description       # Documentation (P3)
test/what-added              # Test additions (P3)
feat/short-description       # New features (P2)
fix/issue-number-description # Bug fixes (P2)
refactor/what-changed        # Code improvements (P2)
security/what-fixed          # Security fixes (P1-2)
```

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):
```
<type>(<scope>): <description>

[optional body]

[optional footer]
