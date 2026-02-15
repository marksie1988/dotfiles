# Zsh Configuration Modules

This directory contains the modular components of the Zsh configuration.

## Structure

- `zshrc.sh`: Core shell configuration (aliases, exports, etc.).
- `zshrc_manager.sh`: Dependency management, updates, and setup logic.
- `config.sh`: Centralized configuration variables (package lists, versions).
- `installers/`: Specialized installation scripts for various tools.
  - `eza.sh`: Modern `ls` replacement.
  - `helix.sh`: Helix editor.
  - `macos_defaults.sh`: macOS system preferences.
  - `optional.sh`: Interactive prompts for optional GUI/CLI tools.
  - `keys.sh`: SSH and GPG key management.
- `logs/`: Setup and update logs.

## Setup

To run the full setup (including optional packages and system defaults), execute:

```zsh
source ~/.zsh/zshrc_manager.sh --setup
```

## Profiling

To profile the shell startup time, run:

```zsh
ZSH_PROFILE=1 zsh
```
