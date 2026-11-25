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

## Packages moved from /etc/nixos

The Nix packages that used to live in the host configuration's `packages/`
directory (the fetch-and-wrap recipes for the small CLI/GUI tools) live in
`packages/` here and are wired in `overlays/migrated.nix`. `overlay.nix` returns
their top-level attribute names as well as the `neg` namespace, so a consumer
can address both. `lib/mkMeta.nix` and `lib/mkCraftApp.nix` are the shared
builders those package files use.
