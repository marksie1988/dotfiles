# Nix setup — how it works & how to change it

A practical guide to this repo's Nix configuration. If you just want to *do* a
thing (add a tool, change a setting), jump to [Cookbook](#cookbook).

## Why it looks more complicated (it isn't, really)

The Nix config is ~30% *fewer* lines than the old shell setup it replaced. What
changed is the *shape*:

| | Old (shell) | New (Nix) |
|---|---|---|
| Model | **Imperative** — a script runs top-to-bottom, does things | **Declarative** — you describe the end state, Nix makes it so |
| Install a tool | A whole installer: brew/apt/curl, arch detection, "skip if present" | One word in a list |
| When it runs | Every shell launch (checks, pulls, installs) | Only when you run `switch` |
| If it breaks | Debug a running script | Build fails *before* anything changes; nothing is half-applied |
| Versions | "latest" — drifts between machines | Pinned in `flake.lock` — identical everywhere |

The cost is real but one-time: **Nix is a new language**, and there's an explicit
file structure instead of one script. Once the model clicks, day-to-day changes
are usually a one-line edit.

## The mental model

You **never edit files in `$HOME` directly** anymore. You edit files *here*, then
run `switch`, and Nix generates `~/.zshrc`, `~/.gitconfig`, `~/.config/...` etc.
(as read-only symlinks into `/nix/store`). To change your shell, edit
`home/zsh.nix` — not `~/.zshrc`.

Flow:

```
edit a .nix file  →  darwin-rebuild switch  →  Nix builds a new "generation"  →  symlinks swapped atomically
                                                                                 (old generation kept for rollback)
```

## Structure

```
flake.nix            The entry point. Declares inputs (nixpkgs, home-manager,
                     nix-darwin) and two outputs:
                       • darwinConfigurations."Stevens-MacBook-Pro"  (macOS)
                       • homeConfigurations."stevenmarks@linux"      (Linux/WSL2)
                     Both pull in the same home/ modules.

flake.lock           Auto-generated. The exact pinned versions of every input.
                     This is what stops machine drift. Commit it.

hosts/darwin.nix     macOS-only, system level (nix-darwin): macOS defaults,
                     Homebrew casks, fonts, Nix settings.

home/                Your user environment (home-manager), shared by mac + Linux:
  default.nix          Imports the others; env vars, PATH, file symlinks, SSH.
  options.nix          Feature flags (dotfiles.*) — the customisation surface.
  packages.nix         CLI tools that are "just install it" (a plain list).
  cli.nix              Tools with settings: fzf, ripgrep, eza, zoxide, atuin,
                       direnv, starship.
  zsh.nix              Aliases, history, functions, keybindings, prompt init.
  git.nix              git config + delta + aliases.
  tmux.nix             tmux config.
  vscode.nix           VS Code extensions.
  ghostty.nix          Ghostty terminal config.
  neovim.nix           Neovim + build tools; config symlinked from config/nvim.
  npm-globals.nix      npm globals not in nixpkgs (gemini-cli).
  herdr.nix            herdr on Linux (installer); macOS uses Homebrew.

config/              Raw config files kept verbatim (starship.toml, k9s, helix,
                     bat, nvim), symlinked into place by home-manager.

setup/bootstrap.sh   First-run: installs Nix + Homebrew, runs the first switch.
```

### How the wiring works

- `flake.nix` defines *what a machine is*: it combines `hosts/darwin.nix` (system)
  with the `home/` modules (user), and passes `username` in via `extraSpecialArgs`.
- Every file in `home/` is a **module**: a function `{ pkgs, ... }: { ... }` that
  returns configuration. `home/default.nix` lists them in `imports`, and
  home-manager **merges them all together**. Order doesn't matter; splitting into
  files is purely for readability.

## Nix syntax you'll actually meet

You don't need to *learn Nix* to maintain this — just recognise five things:

```nix
{ pkgs, lib, ... }:      # module header: "give me pkgs and lib, ignore the rest"
{
  home.packages = [ pkgs.jq pkgs.wget ];   # a list  [ a b c ]  (space-separated!)

  programs.git = {                          # an attribute set  { key = value; }
    enable = true;                          # every line ends with ;
    userName = "Steven Marks";              # strings in "..."
  };

  home.packages = with pkgs; [ jq wget ];   # `with pkgs;` = "prefix these with pkgs."
}
```

**The one genuinely weird bit — `''${` in `home/zsh.nix`.** Nix multi-line strings
use `''...''`, and inside them `${...}` means "Nix, substitute this value". But
shell code *also* uses `${VAR}`. So to keep a `${...}` literal for the shell, you
write `''${...}`:

```nix
initContent = ''
  alias path='echo -e ''${PATH//:/\n}'   # the ''$ keeps ${PATH...} for the shell
'';
```

If you add shell to `zsh.nix` and a `${VAR}` should reach the shell, write it as
`''${VAR}`. That's the only escaping rule you need here.

## Cookbook

After **any** change, apply it with:

```sh
dfup          # shorthand for: darwin-rebuild switch --flake ~/repos/personal/dotfiles#Stevens-MacBook-Pro
```

Test first without touching your system:

```sh
darwin-rebuild build --flake .#Stevens-MacBook-Pro   # builds; activates nothing
```

### Add a CLI tool
Is it in nixpkgs? Check at <https://search.nixos.org/packages>. If yes, add its
name to the list in `home/packages.nix`:

```nix
home.packages = with pkgs; [
  jq wget
  ncdu          # ← added
];
```

### Add an alias
`home/zsh.nix`, in `shellAliases`:

```nix
shellAliases = {
  gs = "git status -s";
  gl = "git log --oneline";   # ← added
};
```

### Add a shell function or keybinding
`home/zsh.nix`, inside `initContent = ''  ... ''`. It's literal zsh — just
remember the `''${...}` rule for shell variables.

### Add a GUI app (macOS)
`hosts/darwin.nix`, in `homebrew.casks`:

```nix
casks = [ "ghostty" "visual-studio-code" "rectangle" ];   # ← added
```

### Change a macOS system default
`hosts/darwin.nix`, under `system.defaults`. Named options live under
`dock` / `finder` / `NSGlobalDomain`; anything else goes in `CustomUserPreferences`
(keyed by the `defaults` domain, e.g. `"com.apple.Safari"`).

### Change a tool's config
- Has a `programs.*` block (git, tmux, fzf…): edit that module.
- Symlinked verbatim (starship, k9s, helix, bat, ghostty, **nvim**): edit the file
  under `config/` (e.g. `config/nvim/init.lua`) then `dfup`.

**Editor:** Neovim (kickstart-style, `config/nvim/init.lua`) is the default —
`$EDITOR`, git, and the `vi`/`vim`/`nano` aliases all point at it. Helix is still
installed (`hx`) during the transition; drop it from `home/packages.nix` once
you're settled.

### Update everything to latest
```sh
nix flake update    # bumps flake.lock to newest nixpkgs/home-manager/etc.
dfup                # rebuild with the new versions
```

### Turn a feature on/off (customisation)
The old interactive `optional.sh` prompts are replaced by **declarative feature
flags** in `home/options.nix` (the `dotfiles.*` options). Change a default there
to change what a fresh install gets:

```nix
# home/options.nix
apps.vscode.enable = lib.mkOption { ... default = false; ... };   # opt out of VS Code extensions
```

…or override per-machine without touching the defaults, in `hosts/<host>.nix`:

```nix
dotfiles.apps.vscode.enable = false;   # this Mac: skip VS Code extensions
```

Current flags: `dotfiles.apps.{ghostty,vscode}.enable`. Add new ones by declaring
an option in `home/options.nix` and gating the code with
`lib.mkIf config.dotfiles.<flag>`.

### Undo a bad change
```sh
darwin-rebuild --rollback     # jump back to the previous generation
# or, before switching, just: git checkout .
```

## Gotchas specific to this repo

- **`flake.lock` is the point.** Commit it. Deleting it un-pins everything.
- **Homebrew `cleanup`** is set to `"none"` in `hosts/darwin.nix` so it won't touch
  casks you installed by hand. Set it to `"zap"` only if you want Nix to own 100%
  of your casks (it will uninstall anything not listed).
- **herdr** is cross-platform but installed differently per OS, because its Nix flake
  builds from source (Rust + Zig, no binary cache) and is slow: **macOS** uses the fast
  prebuilt Homebrew bottle (`homebrew.brews` in `hosts/darwin.nix`); **Linux** runs the
  official installer via `home/herdr.nix` (prebuilt binary → `~/.local/bin`). Both track
  "latest" rather than a pinned version.
- **This repo is standalone.** It has no dependency on any private repo, so anyone
  can clone and build it.
- **AI agent config is not managed here.** Claude/Gemini/Codex/Cursor instructions
  and Claude skills live in the separate private `dotfiles-agents` repo (imperative
  symlinks + Skills CLI), intentionally outside Nix.
- The first switch backs up any pre-existing managed files to `*.bak`
  (`home-manager.backupFileExtension`). Keep secrets out of this public repo.

## Public base + private overlay

This repo is the **public base** — standalone, shareable, safe. Personal/sensitive
config lives in a separate **private** repo (`dotfiles-priv`) that *wraps* this one:

```
dotfiles-priv/flake.nix   inputs.dotfiles = this repo (local path)
                          darwinConfigurations."Stevens-MacBook-Pro" =
                            [ dotfiles.darwinModules.default  ./overlay.nix ]
```

- **Servers / other people** build this public flake directly
  (`home-manager switch --flake …#stevenmarks@linux`). No private content, no secrets.
- **Your local Macs** build the private overlay flake
  (`darwin-rebuild switch --flake ~/repos/personal/dotfiles-priv#Stevens-MacBook-Pro`).
  It layers on the SSH client config (`~/.ssh/config`, internal hosts) and repoints
  `dfup` here via `dotfiles.flakeRef`.
- **AI agent config** is a third, separate private repo (`dotfiles-agents`),
  applied by its own `bootstrap.sh` — not by Nix.
- **SSH private keys / tokens** live in *none* of the repos — generated per machine.

The public repo exposes `darwinModules.default` / `homeModules.default` for the
overlay to consume. Because the overlay uses the public repo as a **local-path**
input, working-tree edits here are picked up on the next `dfup` — no push needed.

## Learn more

- Package search: <https://search.nixos.org/packages>
- home-manager options: <https://nix-community.github.io/home-manager/options.xhtml>
- nix-darwin options: <https://nix-darwin.github.io/nix-darwin/manual/>
