{ lib, pkgs, config, ... }:
let
  prefix = "${config.home.homeDirectory}/.npm-global";
in
{
  # pnpm is a Nix package (see packages.nix). gemini-cli isn't in nixpkgs, so
  # it's installed globally via npm on activation into a writable prefix
  # (the Nix-provided nodejs store path is read-only). Network is required.
  home.sessionVariables.NPM_CONFIG_PREFIX = prefix;
  home.sessionPath = [ "${prefix}/bin" ];

  home.activation.npmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "${prefix}/bin/gemini" ]; then
      run ${pkgs.nodejs}/bin/npm install -g --prefix "${prefix}" \
        @google/gemini-cli
    fi
  '';
}
