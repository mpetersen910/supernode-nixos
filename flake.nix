{
  description = "supernode (Beelink SER5 Pro) - NixOS configuration";

  inputs = {
    # Stable channel for the base system
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Unstable channel for fast-moving tools (Claude Code, Codex)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Build with: sudo nixos-rebuild switch --flake .#supernode
      nixosConfigurations.supernode = nixpkgs.lib.nixosSystem {
        # The platform (x86_64-linux) comes from nixpkgs.hostPlatform
        # in hardware-configuration.nix.

        # Anything in specialArgs becomes a module argument,
        # e.g. { pkgs, pkgs-unstable, ... }: in dev.nix
        specialArgs = { inherit pkgs-unstable; };

        modules = [ ./configuration.nix ];
      };
    };
}
