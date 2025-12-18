{
  description = "Paraglide.nvim - Neovim plugin for Paraglide.js translations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          paraglide-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "paraglide.nvim";
            version = self.shortRev or "dirty";
            src = self;
          };
        };

        defaultPackage = self.packages.${system}.paraglide-nvim;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            neovim
            lua
            stylua
            luacheck
          ];
        };
      }
    );
}

