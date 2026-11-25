{
  description = "neg-serg's custom NixOS packages";

  inputs = {
    # Pinned to the revision /etc/nixos runs, so a standalone build here and the
    # host build resolve to the same derivations. A consumer overrides it with
    # `inputs.neg-pkgs.inputs.nixpkgs.follows = "nixpkgs"` (the host does).
    nixpkgs.url = "github:NixOS/nixpkgs/2786a2a72088ecf32aea5b3ec52099e6a7cff78f";

    # External flake-based packages
    skwd = {
      url = "github:liixini/skwd";
      flake = false;
    };
    skwd-daemon = {
      url = "github:liixini/skwd-daemon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    exo = {
      url = "github:debuggyo/Exo";
      flake = false;
    };
    rsmetrx = {
      url = "github:neg-serg/rsmetrx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    talktype = {
      url = "github:lmacan1/talktype";
      flake = false;
    };
    sqlit = {
      url = "github:Maxteabag/sqlit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wl = {
      url = "github:neg-serg/wl";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    in
    {
      packages = forAllSystems (system: import ./packages.nix { pkgs = mkPkgs system; });
      overlays.default = import ./overlay.nix inputs;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
