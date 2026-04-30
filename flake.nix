{
  description = "Minimal package definition for aarch64-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    arto.url = "github:arto-app/Arto";
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , neovim-nightly-overlay
    , flake-utils
    , arto
    }:
    let
      # 端末ごとの Darwin 設定を生成するヘルパー関数
      mkDarwinConfig = { system, username }:
        let
          homeDirectory = "/Users/${username}";
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit home-manager username homeDirectory; };
          modules = [
            ./nix/nix-darwin/config.nix
            {
              nixpkgs.config.allowUnfreePredicate = pkg:
                builtins.elem (nixpkgs.lib.getName pkg) [
                  "zsh-abbr"
                ];
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit username homeDirectory;
                arto-pkg = arto.packages.${system}.default;
              };
              home-manager.users.${username} = import ./nix/home-manager/default.nix;
            }
          ];
        };
    in
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgsConfig = import ./nix/pkgs.nix { inherit nixpkgs system neovim-nightly-overlay; };
        pkgs = pkgsConfig.pkgs;
      in
      {
        packages.uho = pkgsConfig.uho;

        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixd
              nil
            ];
          };

          go = pkgs.mkShell {
            packages = with pkgs; [
              gopls
              gotools
              golangci-lint
            ];
            shellHook = ''
              unset GOROOT
            '';
          };

          python = pkgs.mkShell {
            packages = with pkgs; [
              uv
              python3
              ruff
            ];
          };

          ts = pkgs.mkShell {
            packages = with pkgs; [
              nodejs
              pnpm
              typescript
              nodePackages.typescript-language-server
            ];
          };
        };

        apps.update = {
          type = "app";
          program = toString (pkgs.writeShellScript "update-script" ''
            set -e
            CONFIG="''${1:-work}"
            echo "Updating flake..."
            nix flake update
            echo "Updating nix-darwin ($CONFIG)..."
            darwin-rebuild switch --flake ".#$CONFIG" || echo "WARNING: darwin-rebuild failed, continuing..."
            echo "Upgrading uho package..."
            nix profile upgrade uho
            echo "Update complete!"
          '');
        };
      }
    )) // {
      darwinConfigurations.work = mkDarwinConfig { system = "aarch64-darwin"; username = "kazuki.iwasaki"; };
      darwinConfigurations.private = mkDarwinConfig { system = "aarch64-darwin"; username = "kazu-gor"; };
    };
}
