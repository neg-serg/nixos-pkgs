{
  description = "neg-serg's custom NixOS packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # External flake-based packages
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    openagentscontrol = {
      url = "github:darrenhinde/OpenAgentsControl";
      flake = false;
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
