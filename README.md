# Dotfiles

Personal development environment config, managed with [yadm](https://yadm.io/).

## Supported platforms

- **macOS** (primary) — Homebrew for package installs.
- **Debian / Ubuntu** — `apt` + per-tool installers for packages not in apt (atuin, lazygit, delta).

Other distros may work but are not regularly tested.

## Install

```sh
# 1. Install yadm + zsh + a Nerd Font-capable terminal (e.g. Ghostty).
#    macOS:
brew install yadm zsh
#    Debian/Ubuntu:
sudo apt install -y yadm zsh curl git

# 2. Make zsh your login shell.
chsh -s "$(which zsh)"

# 3. Clone this repo into your home directory.
yadm clone https://github.com/marksie1988/dotfiles.git

# 4. Start a new zsh session. The bootstrap (.zsh/zshrc_manager.sh) will
#    install the rest of the tooling the first time.
exec zsh
```

On first launch, the bootstrap runs installers in `.zsh/installers/` in parallel. Progress is logged to `~/.zsh/logs/setup.log`. A marker at `~/.zsh/.setup_done` prevents re-running — delete it or pass `--setup` to re-run.

Daily runs check for upstream dotfile updates via `yadm fetch --tags` at most once every 24h.

## What's in here

| Path | What |
|------|------|
| `.zshrc` | Entry point, sources `.zsh/zshrc_manager.sh`. |
| `.zsh/` | Modular shell config: aliases, functions, exports, plugins, keybindings. |
| `.zsh/installers/` | Per-tool install scripts. Follow the `install_<tool>` function pattern. |
| `.gitconfig` | Git config, delta diff rendering, fzf-backed aliases (`git a`, `git df`, `git find`). |
| `.tmux.conf` | tmux config, Tokyo Night theme, prefix `Ctrl+t`. |
| `.config/helix/` | Helix editor config. |
| `.config/k9s/` | k9s config and Tokyo Night skin. |
| `.config/bat/` | bat config. |
| `.config/starship.toml` | Starship prompt. |
| `.ripgreprc` | ripgrep defaults (smart-case, hidden, ignore .git). |
| `SHORTCUTS.md` | Full alias/keybinding reference. |
| `AGENTS.md` | Rules for AI agents working in this repo. |

## Secrets / local overrides

Put machine-specific secrets in `~/.env.local` (gitignored). It's sourced at the top of `~/.zshrc`:

```sh
export ANTHROPIC_API_KEY=...
export GITHUB_TOKEN=...
export TMUX_AUTOSTART=1   # opt in to tmux auto-attach
```

## Contributing / linting

```sh
# Local
pre-commit install           # run shellcheck + shfmt + zsh -n on commit

# Manual
shellcheck .zsh/*.sh .zsh/installers/*.sh
for f in .zsh/**/*.sh(.); do zsh -n "$f"; done
```

CI runs the same checks on push / PR (`.github/workflows/lint.yml`).

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). Copyright © [Total Debug](https://totaldebug.uk).
