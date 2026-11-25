inputs: final: prev:
let
  inherit (final) lib;
  callPkg = path: final.callPackage (./packages + "/${path}") { };

  # Packages moved here from /etc/nixos/packages/ (2026-11-25). They keep their
  # attribute paths: `neg` names are merged below, the rest become top-level
  # attributes — which this overlay never returned before, so every domain
  # overlay's top-level entry was computed and dropped.
  migrated = import ./overlays/migrated.nix { inherit inputs final prev; };
in
migrated
// {

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
      raysession = prev.raysession.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/gui/patchbay/patchcanvas/portgroup_widget.py \
            --replace-fail "from cgitb import text" ""
        '';
      });
    }
    // (migrated.neg or { });

  # Python with LTO optimizations
  python3-lto = prev.python3.override {
    packageOverrides = _pythonSelf: _pythonSuper: {
      enableOptimizations = true;
      enableLTO = true;
      reproducibleBuild = false;
    };
  };

  # keyutils fix not available in standalone — handled by main config overlay

  # Fix /sbin/ldconfig symlink in FHS envs (Steam pressure-vessel nested container fix)
  buildFHSEnv = args: prev.buildFHSEnv (args // {
    extraBuildCommands = (args.extraBuildCommands or "") + ''
      if [ -L $out/usr/sbin/ldconfig ] && [ -f $out/usr/bin/ldconfig ]; then
        cp -f $out/usr/bin/ldconfig $out/usr/sbin/ldconfig
      fi
    '';
  });
}
