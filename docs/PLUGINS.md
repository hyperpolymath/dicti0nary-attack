# Plugin Development Guide

The dicti0nary-attack tool supports a plugin architecture for extending functionality with custom generators, crackers, and other features.

## Plugin Structure

A plugin is a Python module that registers components with the plugin manager.

### Basic Plugin Example

```python
# my_plugin.py

from dicti0nary_attack.generators.base import PasswordGenerator
from typing import Iterator, Optional


class MyCustomGenerator(PasswordGenerator):
    """Custom password generator."""

    def generate(self, count: Optional[int] = None) -> Iterator[str]:
        """Generate custom passwords."""
        generated = 0

        while count is None or generated < count:
            # Your password generation logic
            password = f"custom_password_{generated}"

            if self.apply_filters(password):
                self.stats['generated'] += 1
                generated += 1
                yield password


def register(plugin_manager):
    """Register this plugin."""
    plugin_manager.register_generator('my_custom', MyCustomGenerator)
```

## Using Plugins

### Loading Plugins Programmatically

```python
from dicti0nary_attack.plugins import plugin_manager

# Load a single plugin
plugin_manager.load_plugin('my_plugins.custom_gen')

# Load all plugins from a directory
plugin_manager.load_plugins_from_directory('plugins/')

# Use the custom generator
CustomGen = plugin_manager.get_generator('my_custom')
gen = CustomGen()

for password in gen.generate(count=10):
    print(password)
```

### Plugin Directory Structure

```
my_project/
├── plugins/
│   ├── __init__.py
│   ├── custom_generator.py
│   ├── advanced_cracker.py
│   └── utils.py
└── main.py
```

## Creating Custom Generators

Custom generators must inherit from `PasswordGenerator`:

```python
from dicti0nary_attack.generators.base import PasswordGenerator
from typing import Iterator, Optional, Dict, Any


class AdvancedGenerator(PasswordGenerator):
    """Advanced custom generator with configuration."""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        super().__init__(config)
        self.custom_param = self.config.get('custom_param', 'default')

    def generate(self, count: Optional[int] = None) -> Iterator[str]:
        """Generate passwords."""
        generated = 0

        for i in range(count or 1000):
            # Use configuration
            password = f"{self.custom_param}_{i}"

            # Apply built-in filters (length, etc.)
            if self.apply_filters(password):
                self.stats['generated'] += 1
                generated += 1
                yield password

            if count and generated >= count:
                break


def register(plugin_manager):
    """Register the generator."""
    plugin_manager.register_generator('advanced', AdvancedGenerator)
```

## Creating Custom Crackers

Custom crackers can extend hash cracking capabilities:

```python
from dicti0nary_attack.crackers.hash_cracker import HashCracker
from typing import Iterator, Optional


class CustomCracker(HashCracker):
    """Custom hash cracker with additional features."""

    def crack_with_transformations(self, target_hash: str, passwords: Iterator[str]):
        """Crack with automatic transformations."""
        for password in passwords:
            # Try original
            computed = self.hash_password(password, self.algorithm)
            if computed == target_hash:
                return password

            # Try uppercase
            upper = password.upper()
            computed = self.hash_password(upper, self.algorithm)
            if computed == target_hash:
                return upper

            # Try reversed
            reversed_pwd = password[::-1]
            computed = self.hash_password(reversed_pwd, self.algorithm)
            if computed == target_hash:
                return reversed_pwd

        return None


def register(plugin_manager):
    """Register the cracker."""
    plugin_manager.register_cracker('custom', CustomCracker)
```

## Plugin Configuration

Plugins can accept configuration:

```python
class ConfigurableGenerator(PasswordGenerator):
    """Generator with extensive configuration."""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        super().__init__(config)

        # Plugin-specific configuration
        self.prefix = self.config.get('prefix', '')
        self.suffix = self.config.get('suffix', '')
        self.separator = self.config.get('separator', '-')
        self.word_list = self.config.get('word_list', [])

    def generate(self, count: Optional[int] = None) -> Iterator[str]:
        """Generate configured passwords."""
        for i in range(count or len(self.word_list)):
            word = self.word_list[i % len(self.word_list)]
            password = f"{self.prefix}{self.separator}{word}{self.separator}{self.suffix}"

            if self.apply_filters(password):
                self.stats['generated'] += 1
                yield password
```

Usage:

```python
config = {
    'prefix': 'secure',
    'suffix': '2024',
    'separator': '_',
    'word_list': ['alpha', 'beta', 'gamma'],
    'min_length': 8
}

gen = ConfigurableGenerator(config=config)
passwords = list(gen.generate(count=10))
```

## Best Practices

### 1. Follow Base Class Contracts

Always call parent `__init__` and implement required methods:

```python
class MyGenerator(PasswordGenerator):
    def __init__(self, config=None):
        super().__init__(config)  # Important!

    def generate(self, count=None) -> Iterator[str]:
        # Implementation
        pass
```

### 2. Use Filters

Leverage built-in filtering:

```python
def generate(self, count=None):
    for password in self._generate_raw():
        if self.apply_filters(password):  # Uses min_length, max_length, etc.
            yield password
```

### 3. Track Statistics

Update statistics for monitoring:

```python
def generate(self, count=None):
    for password in candidates:
        if self.apply_filters(password):
            self.stats['generated'] += 1  # Track successful generations
            yield password
        else:
            self.stats['filtered'] += 1  # Track filtered out
```

### 4. Handle Configuration Gracefully

Provide sensible defaults:

```python
def __init__(self, config=None):
    super().__init__(config)
    self.param = self.config.get('param', 'default_value')
```

### 5. Document Your Plugin

Provide comprehensive docstrings:

```python
class MyGenerator(PasswordGenerator):
    """
    My custom password generator.

    This generator creates passwords by combining words from a custom
    dictionary with numbers and special characters.

    Configuration:
        word_source (str): Source for words ('file' or 'builtin')
        word_file (str): Path to word file if word_source is 'file'
        min_numbers (int): Minimum numbers to append (default: 2)
        max_numbers (int): Maximum numbers to append (default: 4)

    Example:
        >>> config = {'word_source': 'builtin', 'min_numbers': 3}
        >>> gen = MyGenerator(config=config)
        >>> passwords = list(gen.generate(count=10))
    """
```

## Testing Plugins

Create tests for your plugins:

```python
# test_my_plugin.py

import pytest
from my_plugins.custom_gen import MyCustomGenerator


def test_generator_basic():
    """Test basic generation."""
    gen = MyCustomGenerator()
    passwords = list(gen.generate(count=10))

    assert len(passwords) == 10
    assert all(isinstance(p, str) for p in passwords)


def test_generator_with_config():
    """Test generator with configuration."""
    config = {'custom_param': 'test', 'min_length': 8}
    gen = MyCustomGenerator(config=config)
    passwords = list(gen.generate(count=5))

    assert len(passwords) == 5
    for pwd in passwords:
        assert len(pwd) >= 8
        assert 'test' in pwd
```

## Publishing Plugins

To share your plugin:

1. **Create a package structure**:
   ```
   my-dicti0nary-plugin/
   ├── README.md
   ├── setup.py
   └── dicti0nary_plugins/
       ├── __init__.py
       └── my_plugin.py
   ```

2. **Write setup.py**:
   ```python
   from setuptools import setup, find_packages

   setup(
       name='dicti0nary-plugin-custom',
       version='0.1.0',
       packages=find_packages(),
       install_requires=['dicti0nary-attack'],
   )
   ```

3. **Publish to PyPI** or share on GitHub

## Example Plugins

### Word Combiner Generator

```python
import itertools
from dicti0nary_attack.generators.base import PasswordGenerator


class WordCombinerGenerator(PasswordGenerator):
    """Combines multiple words with separators."""

    def __init__(self, words=None, config=None):
        super().__init__(config)
        self.words = words or ['alpha', 'beta', 'gamma']
        self.separators = self.config.get('separators', ['', '-', '_', '.'])

    def generate(self, count=None):
        generated = 0

        for combo in itertools.combinations(self.words, 2):
            for sep in self.separators:
                password = sep.join(combo)

                if self.apply_filters(password):
                    self.stats['generated'] += 1
                    generated += 1
                    yield password

                    if count and generated >= count:
                        return


def register(plugin_manager):
    plugin_manager.register_generator('word_combiner', WordCombinerGenerator)
```

## Getting Help

- Review built-in generators in `src/dicti0nary_attack/generators/`
- Check the base classes for available methods
- Open an issue for plugin development questions
- Share your plugins with the community!
