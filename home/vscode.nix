{ config, lib, ... }:
{
  # VS Code itself is installed as a Homebrew cask (see hosts/darwin.nix).
  # Its extensions (was optional.sh) are installed best-effort on activation —
  # this never fails the switch, since `code` only exists once the cask is in.
  home.activation.vscodeExtensions = lib.mkIf config.dotfiles.apps.vscode.enable (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
      if [ -x "$code_bin" ]; then
        for ext in ms-python.python ms-toolsai.jupyter; do
          run "$code_bin" --install-extension "$ext" --force || true
        done
      fi
    ''
  );
}
