inputs: final: prev:
let
  inherit (final) lib;
  callPkg = path: final.callPackage (./packages + "/${path}") { };

  # External flake packages
  zen-browser = inputs.zen-browser.packages.${final.stdenv.hostPlatform.system}.default;
in
{
  # Override opencode from flake input (latest git)
  opencode = (final.callPackage "${inputs.nixpkgs}/pkgs/by-name/op/opencode/package.nix" { }).overrideAttrs (old: {
    src = inputs.opencode;
    version = inputs.opencode.shortRev or "dev-${inputs.opencode.lastModifiedDate}";
    node_modules = old.node_modules.overrideAttrs (nmOld: {
      outputHash = "sha256-Z3ZDYxUHCcmEaYvl8qlKqkBGOPvZaKzTZ8fiXzbXm48=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    });
  });

  # Merge all package categories into the neg namespace
  neg =
    let
      tools = import ./overlays/tools.nix inputs final prev;
      media = import ./overlays/media.nix inputs final prev;
      dev = import ./overlays/dev.nix inputs final prev;
      gui = import ./overlays/gui.nix inputs final prev;
      functions = import ./overlays/functions.nix inputs final prev;
      fonts = import ./overlays/fonts.nix inputs final prev;
      aurPorted = import ./overlays/aur-ported.nix final prev;
      disableChecks = import ./overlays/disable-checks.nix inputs final prev;
    in
    (functions.neg or { })
    // (tools.neg or { })
    // (media.neg or { })
    // (dev.neg or { })
    // (gui.neg or { })
    // aurPorted
    // disableChecks
    // {
      rofi-config = final.callPackage ./packages/rofi-config { };
      opencode-dev = (final.callPackage "${inputs.nixpkgs}/pkgs/by-name/op/opencode/package.nix" { }).overrideAttrs (old: {
        src = inputs.opencode;
        version = inputs.opencode.shortRev or "dev-${inputs.opencode.lastModifiedDate}";
      });
      raysession = prev.raysession.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/gui/patchbay/patchcanvas/portgroup_widget.py \
            --replace-fail "from cgitb import text" ""
        '';
      });
    };

  # Python with LTO optimizations
  python3-lto = prev.python3.override {
    packageOverrides = _pythonSelf: _pythonSuper: {
      enableOptimizations = true;
      enableLTO = true;
      reproducibleBuild = false;
    };
  };

  # Fix keyutils patch download failing (upstream lore.kernel.org 403)
  keyutils = prev.keyutils.overrideAttrs (old: {
    patches = (old.patches or [ ])
      |> builtins.map (
        p:
        if builtins.isAttrs p && (p.name or "") == "raw" then
          ./packages/../files/patches/keyutils-fix-format-specifier.patch
        else
          p
      );
  });

  # Fix /sbin/ldconfig symlink in FHS envs (Steam pressure-vessel nested container fix)
  buildFHSEnv = args: prev.buildFHSEnv (args // {
    extraBuildCommands = (args.extraBuildCommands or "") + ''
      if [ -L $out/usr/sbin/ldconfig ] && [ -f $out/usr/bin/ldconfig ]; then
        cp -f $out/usr/bin/ldconfig $out/usr/sbin/ldconfig
      fi
    '';
  });
}
