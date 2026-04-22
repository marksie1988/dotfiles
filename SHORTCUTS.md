# Dotfiles Shortcuts & Configuration

This document provides a comprehensive overview of the custom shortcuts, aliases, and configurations implemented in these dotfiles.

## Zsh Aliases

### Navigation
- `..`, `...`, `....`, `.....`: Navigate up multiple directory levels.
- `~`: Change directory to home.
- `-`: Change directory to the previous path.

### Git
- `g`: `git`
- `gs`: `git status -s`
- `gf`: `git fetch --prune`
- `gpl`: `git pull`
- `gplr`: `git pull --rebase`
- `gps`: `git push`
- `gpsh`: Push current branch to origin.
- `gcb`: `git checkout -b`
- `grs`: `git reset`
- `gresethard`: `git reset --hard` (spelled out intentionally — destructive).
- `gcm`: Stage all changes and commit with a message.
- `undo`: Undo the last commit (mixed reset).
- `gr`: `git remote -v`
- `ssha`: Start ssh-agent and add keys.
- `gum`: Fetch and merge from upstream master.
- `lg`: `lazygit` (interactive TUI).

### Development & Tools
- `k`: `kubectl`
- `h`: `helm`
- `tf`: `tofu`
- `tg`: `terragrunt`
- `a`: `ansible`
- `ap`: `ansible-playbook`
- `vi`, `nano`: Alias to `hx` (Helix).
- `code`: Open Visual Studio Code.
- `ls`, `ll`: Enhanced directory listing via `eza`.
- `tree`: Tree view via `eza`.
- `path`: Print each PATH entry on a new line.

### System & Network
- `pubip`: Get public IP address.
- `localip`: Get local IP address.
- `df`, `du`: Human-friendly disk usage.
- `t`, `ta`: `tmux` and `tmux attach`.

## Zsh Keybindings

- `Ctrl + s`: Prepend `sudo` to the current command line.
- `Ctrl + g`: Prepare a git commit (stages all, commits with buffer content or opens editor, and pushes).
- `Ctrl + h`: Change directory to the git repository root.
- `Up/Down Arrows`: Beginning-of-line history search.
- `Ctrl + r`: atuin shell history search (replaces default Ctrl+r).
- `Ctrl + t`: fzf file picker (insert a file path into the current command).
- `Alt + c`: fzf cd-to-subdirectory.
- `Home/End/Delete`: Standard line navigation and character deletion.

## Shell Integrations

- `cd <partial>`: zoxide-backed — jumps to most-frecent matching directory.
- `direnv`: auto-loads `.envrc` on entering a directory.
- `TMUX_AUTOSTART=1`: set in `~/.env.local` to auto-attach tmux on every shell.

## Zsh Functions

- `kn <namespace>`: Set the current kubectl namespace.
- `knd`: Reset kubectl namespace to `default`.
- `ku`: Unset current kubectl context.
- `colormap`: Display a 256-color map in the terminal.

## Tmux Shortcuts

- **Prefix**: `Ctrl + t`
- `Prefix + r`: Reload tmux configuration.
- `Prefix + o`: Open the current directory in the OS file manager.
- `Prefix + e`: Kill all other panes.
- `Prefix + h/j/k/l`: Vim-like pane switching.
- `Prefix + Ctrl + h/j/k/l`: Resize panes.
- `Ctrl + a`: Send prefix to a nested tmux session.
- `Ctrl + Shift + Left/Right`: Swap and move between windows.

## Helix Editor

- `Del`: Delete selection.
- `Ctrl + c`: Yank to system clipboard.
- `Space + y`: Join and yank selections to system clipboard (Normal and Select modes).
