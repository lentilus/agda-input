{
  description = "This flake is just for testing.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems
          (system: f system (import nixpkgs { inherit system; }));
    in {
      packages = forAllSystems (system: pkgs:
        let
          src = pkgs.lib.cleanSourceWith {
            src = ./.;
            filter = path: type:
              let rel = pkgs.lib.removePrefix (toString ./.) (toString path);
              in rel == "/lua"
                 || pkgs.lib.hasPrefix "/lua/" rel
                 || builtins.baseNameOf path == "lua";
          };

          agda-input = pkgs.vimUtils.buildVimPlugin {
            name = "agda-input";
            inherit src;
          };

          neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped
            (pkgs.neovimUtils.makeNeovimConfig {
              plugins = [ agda-input ];
              customLuaRC = builtins.readFile ./dev/init.lua;
            });
        in {
          default     = neovim;
        });

      apps = forAllSystems (system: pkgs: {
        default = { type = "app"; program = "${self.packages.${system}.default}/bin/nvim"; };
      });

      devShells = forAllSystems (system: pkgs: {
        default = pkgs.mkShell {
          packages = [ self.packages.${system}.default ];
        };
      });
    };
}
