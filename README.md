# nixos-pkgs

Standalone Nix flake packaging vendored packages from [neg-serg/nixos-config](https://github.com/neg-serg/nixos-config).

## Usage

```nix
# flake.nix
{
  inputs.neg-pkgs.url = "github:neg-serg/nixos-pkgs";
  inputs.neg-pkgs.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = { nixpkgs, neg-pkgs, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.overlays = [ neg-pkgs.overlays.default ]; }
      ];
    };
  };
}
```

## Updating

```bash
# After changing packages in nixos-config:
cd /etc/nixos
git subtree push --prefix=packages/ neg-pkgs main

# After updating packages in this repo:
cd /etc/nixos
git subtree pull --prefix=packages/ neg-pkgs main
```
