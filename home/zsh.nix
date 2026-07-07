{ config, pkgs, ... }:
let
  # Overlay flakes (private) wrap the public base via a `path:` input; override it
  # to the live path so working-tree edits are picked up without re-locking.
  baseOverride =
    if config.dotfiles.baseFlakePath != null then
      '' --override-input dotfiles "path:${config.dotfiles.baseFlakePath}"''
    else
      "";
in
{
  programs.zsh = {
    enable = true;
    # Keep .zshrc in $HOME (current behaviour); the default moves to XDG in 26.05.
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true; # was zsh-users/zsh-autosuggestions
    syntaxHighlighting.enable = true; # was zsh-users/zsh-syntax-highlighting

    history = {
      path = "${config.xdg.cacheHome}/zsh/history";
      size = 100000;
      save = 100000;
      share = true; # SHARE_HISTORY (implies incremental append)
    };

    # Remaining antidote plugins, now supplied declaratively by nixpkgs.
    plugins = [
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "zsh-abbr";
        src = pkgs.zsh-abbr;
        file = "share/zsh/zsh-abbr/zsh-abbr.plugin.zsh";
      }
    ];

    # Straightforward aliases (was .zsh/aliases.sh). Gnarlier ones with shell
    # metacharacters live in initContent below to avoid Nix-string escaping.
    shellAliases = {
      nrb = "npm run build";
      sha256 = "shasum -a 256";
      rand32 = "openssl rand -base64 32";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # Git
      g = "git";
      gs = "git status -s";
      gf = "git fetch --prune";
      gp = "git pull";
      gpr = "git pull --rebase";
      gps = "git push";
      gpsh = "git push -u origin `git rev-parse --abbrev-ref HEAD`";
      gcb = "git checkout -b";
      grs = "git reset";
      gcm = "git add -A && git commit -m";
      undo = "git reset HEAD~1 --mixed";
      gresethard = "git reset --hard";
      gr = "git remote -v";
      ssha = "eval $(ssh-agent) && ssh-add";
      gum = "git fetch upstream && git merge upstream/master";
      lg = "lazygit";

      # Automation / IaC
      k = "kubectl";
      h = "helm";
      tf = "tofu";
      tfp = "tofu plan";
      tfa = "tofu apply";
      a = "ansible";
      ap = "ansible-playbook";
      code = "open -a 'Visual Studio Code'";
      cc = "claude --dangerously-skip-permissions";

      # Editors
      vi = "nvim";
      vim = "nvim";
      nano = "nvim";

      # Listing / misc
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons --group-directories-first -l";
      tree = "eza --tree --icons";
      grep = "grep --color";
      pip = "dig +short myip.opendns.com @resolver1.opendns.com";
      lip = "ipconfig getifaddr en0";
      df = "df -h";
      du = "du -h -d 2";
      t = "tmux";
      ta = "tmux a";
      neofetch = "fastfetch"; # neofetch replaced by fastfetch
    };

    initContent = ''
      # Machine-specific secrets / overrides (gitignored, not managed by Nix).
      [[ -f ~/.env.local ]] && source ~/.env.local

      [ -d ~/.cache/zsh ] || mkdir -p ~/.cache/zsh
      setopt inc_append_history

      export GPG_TTY=$(tty)

      # --- Aliases with shell metacharacters (kept verbatim) ---
      alias -- -='cd -'
      alias '~'='cd ~'
      alias path='echo -e ''${PATH//:/\n}'
      alias shrug="echo '¯\_(ツ)_/¯'"
      alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

      # Force a rebuild from the flake (replaces the old yadm-based `dfup`).
      # The flake ref comes from dotfiles.flakeRef (overridable by an overlay).
      dfup() {
        local flake="${config.dotfiles.flakeRef}"
        if command -v darwin-rebuild >/dev/null 2>&1; then
          darwin-rebuild switch --impure --flake "$flake#Stevens-MacBook-Pro"${baseOverride}
        else
          home-manager switch --impure --flake "$flake#linux"
        fi
      }

      # --- Functions (was .zsh/functions.sh) ---
      kn() {
          if [ "$1" != "" ]; then
              kubectl config set-context --current --namespace=$1
          else
              echo -e "\e[1;31m Error, please provide a valid Namespace\e[0m"
          fi
      }

      knd() {
          kubectl config set-context --current --namespace=default
      }

      ku() {
          kubectl config unset current-context
      }

      colormap() {
        for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}''${(l:3::0:)i}%f " ''${''${(M)$((i%6)):#3}:+$'\n'}; done
      }

      git_prepare() {
          if [ -n "$BUFFER" ]; then
              BUFFER="git add -A && git commit -m \"$BUFFER\" && git push"
          fi
          if [ -z "$BUFFER" ]; then
              BUFFER="git add -A && git commit -v && git push"
          fi
          zle accept-line
      }

      git_root() {
          BUFFER="cd $(git rev-parse --show-toplevel || echo ".")"
          zle accept-line
      }

      add_sudo() {
          BUFFER="sudo "$BUFFER
          zle end-of-line
      }

      # --- Keybindings (was .zsh/keybindings.sh) ---
      zle -N add_sudo
      bindkey "^s" add_sudo
      zle -N git_prepare
      bindkey "^g" git_prepare
      zle -N git_root
      bindkey "^h" git_root
      bindkey "^[[H"  beginning-of-line
      bindkey "^[[F"  end-of-line
      bindkey "^[[1~" beginning-of-line
      bindkey "^[[4~" end-of-line
      bindkey "^[[3~" delete-char

      # Start-typing + arrow keys → prefix history search
      if [[ "''${terminfo[kcuu1]}" != "" ]]; then
          autoload -U up-line-or-beginning-search
          zle -N up-line-or-beginning-search
          bindkey "''${terminfo[kcuu1]}" up-line-or-beginning-search
      fi
      if [[ "''${terminfo[kcud1]}" != "" ]]; then
          autoload -U down-line-or-beginning-search
          zle -N down-line-or-beginning-search
          bindkey "''${terminfo[kcud1]}" down-line-or-beginning-search
      fi

      # --- Distribution / device icon for starship (was .zsh/distribution.sh) ---
      LFILE="/etc/*-release"
      MFILE="/System/Library/CoreServices/SystemVersion.plist"
      if [[ -f $LFILE ]]; then
        _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
      elif [[ -f $MFILE ]]; then
        _distro="macos"
        _device=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3,$4,$5,$6,$7}')
        case $_device in
          *MacBook*)     DEVICE="";;
          *mini*)        DEVICE="󰇄";;
          *)             DEVICE="";;
        esac
      fi
      case $_distro in
          *kali*)                  ICON="ﴣ";;
          *arch*)                  ICON="";;
          *debian*)                ICON="";;
          *raspbian*)              ICON="";;
          *ubuntu*)                ICON="";;
          *elementary*)            ICON="";;
          *fedora*)                ICON="";;
          *coreos*)                ICON="";;
          *gentoo*)                ICON="";;
          *mageia*)                ICON="";;
          *centos*)                ICON="";;
          *opensuse*|*tumbleweed*) ICON="";;
          *sabayon*)               ICON="";;
          *slackware*)             ICON="";;
          *linuxmint*)             ICON="";;
          *alpine*)                ICON="";;
          *aosc*)                  ICON="";;
          *nixos*)                 ICON="";;
          *devuan*)                ICON="";;
          *manjaro*)               ICON="";;
          *rhel*)                  ICON="";;
          *macos*)                 ICON="";;
          *)                       ICON="";;
      esac
      export STARSHIP_DISTRO="$ICON"
      export STARSHIP_DEVICE="$DEVICE"

      # --- Shell integrations, in the exact order the old zshrc.sh used ---
      eval "$(atuin init zsh --disable-up-arrow)"
      eval "$(direnv hook zsh)"
      eval "$(starship init zsh)"
      # zoxide must be last so its hooks run after starship's precmd
      eval "$(zoxide init zsh --cmd cd)"

      # Auto-attach tmux only when opted in via TMUX_AUTOSTART=1
      if [[ "$TMUX_AUTOSTART" == "1" ]] && command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        tmux attach || exec tmux
      fi
    '';
  };
}
