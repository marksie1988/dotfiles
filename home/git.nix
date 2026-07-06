{ ... }:
{
  # delta as git's pager/diff-filter. enableGitIntegration wires core.pager +
  # interactive.diffFilter into the git config.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Nord";
    };
  };

  programs.git = {
    enable = true;

    # Freeform git config (home-manager's `settings` schema).
    settings = {
      user = {
        name = "Steven Marks";
        email = "marksie1988@users.noreply.github.com";
      };
      core.editor = "nvim";
      merge.conflictStyle = "zdiff3";
      diff.colorMoved = "default";
      push.default = "simple";
      color = {
        status = "auto";
        diff = "auto";
        branch = "auto";
        interactive = "auto";
        grep = "auto";
        ui = "auto";
      };
      hub.protocol = "https";

      alias = {
        a = "!git status --short | fzf -m | awk '{print $2}' | xargs git add";
        d = "diff";
        co = "checkout";
        ci = "commit";
        ca = "commit -a";
        ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
        pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
        st = "status";
        br = "branch";
        ba = "branch -a";
        bm = "branch --merged";
        bn = "branch --no-merged";
        df = "!git hist | fzf | awk '{print $2}' | xargs -I {} git diff {}^ {}";
        hist = ''log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
        llog = ''log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
        open = "!hub browse";
        type = "cat-file -t";
        dump = "cat-file -p";
        find = ''!f() { git log --pretty=format:"%h %cd [%cn] %s%d" --date=relative -S"$@" | fzf | awk '{print $1}' | xargs -I {} git diff {}^ {}; }; f'';
        edit-unmerged = ''!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; ''${EDITOR:-nvim} `f`'';
        add-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; git add `f`";
      };
    };

    # Was `[includeIf "gitdir:~/repos/work/"]`.
    includes = [
      {
        condition = "gitdir:~/repos/work/";
        path = "~/repos/work/.gitconfig";
      }
    ];

    # Global excludes (was core.excludesfile = ~/.gitignore under yadm). Now
    # managed as ~/.config/git/ignore — OS/editor cruft only.
    ignores = [
      ".DS_Store"
      "*.o"
      "*~"
      "*.sw[po]"
      "tags"
      "TAGS"
      "*.dSYM"
      "*.log"
      "node_modules"
      ".env.local"
      ".direnv/"
      "result"
    ];
  };
}
