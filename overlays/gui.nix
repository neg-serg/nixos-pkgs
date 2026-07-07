inputs: _: prev:
let
  callPkg =
    path: extraArgs:
    let
      f = import path;
      wantsInputs = builtins.hasAttr "inputs" (builtins.functionArgs f);
      autoArgs = if wantsInputs then { inherit inputs; } else { };
    in
    prev.callPackage path (autoArgs // extraArgs);
in
{
  hyprland-qtutils = prev.hyprland-qtutils.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      for f in $(grep -RIl "Qt6::WaylandClientPrivate" . || true); do
        substituteInPlace "$f" --replace "Qt6::WaylandClientPrivate" "Qt6::WaylandClient"
      done
    '';
  });
  # Avoid pulling hyprland-qtutils into Hyprland runtime closure
  # Some downstream overlays add qtutils to PATH wrapping; disable that.
  hyprland = prev.hyprland.override { wrapRuntimeDeps = false; };
  andromeda-gtk-theme = callPkg (../packages/andromeda-gtk-theme) { };
  flight-gtk-theme = callPkg (../packages/flight-gtk-theme) { };
  matugen-themes = callPkg (../packages/matugen-themes) { };
  oldschool-pc-font-pack = callPkg (../packages/oldschool-pc-font-pack) { };
  surfingkeys-pkg = prev.callPackage (../packages/surfingkeys-conf) {
    customConfig = ../files/surfingkeys.js;
  };
  wl = callPkg (../packages/wl) { };
  gituserchrome = callPkg (../packages/gituserchrome) { }; # Cross-platform tool for git userChrome themes

  # Fix GSettings schema lookup and GTK wrapping for PipeWire graph GUI
  crosspipe = prev.crosspipe.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.wrapGAppsHook ];
    buildInputs = (old.buildInputs or [ ]) ++ [ prev.dconf ];
  });

  skwd = prev.callPackage (../packages/skwd) {
    skwd-src = inputs.skwd;
    skwd-daemon = inputs.skwd-daemon.packages.${prev.stdenv.hostPlatform.system}.default;
  };

  exo = prev.callPackage (../packages/exo) {
    exo-src = inputs.exo;
  };
}
