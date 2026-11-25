# Packages moved out of /etc/nixos/packages/ (2026-11-25).
#
# Their attribute paths are preserved: what the host exposed as pkgs.neg.<name>
# stays under `neg`, the rest are top-level names. Before this file, the domain
# overlays in this repository defined these top-level packages but overlay.nix
# only returned `neg`, so a consumer could never see them.
#
# `call` is the host's `callPkg` without its inputs/paths injection: none of the
# entries below declares those formals, so the two are the same function here.
{ inputs, final, prev }:
let
  call =
    path: extraArgs:
    final.callPackage (../packages + "/${path}") extraArgs;

  # The same wrapper the host applied to these names (`rust-pkgs` lib/slim.nix):
  # LTO, one codegen unit and stripped binaries.
  rustSlim = inputs.rust-pkgs.lib.slim;
in
{
  neg = {
    joern = call "joern" { };
    dnsglobe = rustSlim (call "dnsglobe" { }); # Global DNS propagation checker TUI — record answers on a world map
    flow = call "flow" { }; # Terminal dashboard for real-time network throughput
    geekbench-ai = call "geekbench-ai" { }; # Geekbench AI — on-device inference benchmark (proprietary binary)
    lsfg-vk = call "lsfg-vk" { }; # Vulkan frame-gen layer (LSFG on Linux; needs Lossless Scaling on Steam)
    neru = call "neru" { }; # Desktop keyboard navigation — hints, grids, vim-style modes (upstream main)
    niri-screen-time = call "niri-screen-time" { }; # Screen time tracker by window class/title (niri + Hyprland daemon and report CLI)
    nixard = call "nixard" { }; # TUI for exploring NixOS package closures / generating Nix declarations
    oryx = call "oryx" { }; # TUI for sniffing network traffic using eBPF (needs root + BTF kernel)
    terrascope = call "terrascope" { }; # Interactive world map for the terminal (braille; live weather/aircraft/earthquakes)
    topowall = rustSlim (call "topowall" { }); # Topographic contour wallpapers from real elevation data (GPU render)
    tuigram = call "tuigram" { }; # Terminal UI Telegram client (npm package, Node 26 + node:ffi)
    uutils-sort = call "uutils-sort" { }; # uu_sort patched to compute ICU collation keys in parallel
  };

  # Patched herdr (nixpkgs package plus the tab-appearance patches): the same
  # override the host's tools overlay carried, with the patch paths relative to
  # this file.
  herdr = prev.herdr.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../packages/herdr/patches/0001-ui-per-state-tab-colours-and-font-styles.patch
      ../packages/herdr/patches/0002-ui-tab-title-templates-and-the-active-marker.patch
      ../packages/herdr/patches/0003-docs-document-the-tab-appearance-keys.patch
    ];
  });

  sonda = rustSlim (call "sonda" { }); # file manager for pleamar-wm that searches files by what they hold
  vsncnn = call "vsncnn" { };
  snd-hdspe = call "snd-hdspe" { kernel = prev.linuxPackages.kernel; };
  vivaldi-fixed = call "vivaldi" { }; # patched Vivaldi build (wayland flags, bundled libffmpeg RUNPATH)

atrium = call "atrium" { }; # Wayland multiseat display manager
  audio-cpp = call "audio-cpp" { };
  camillaeq = call "camillaeq" { };
  camillagui = call "camillagui" { }; # web GUI for CamillaDSP
  craft-anything = rustSlim (call "craft-anything" { }); # reverse-engineering workbench + rebuild assistant (desktop app, CLI, MCP server)
  figcraft = rustSlim (call "figcraft" { }); # interface design and prototyping
  hdspeconf = call "hdspeconf" { };
  hypr-kdeconnect-fix = call "hypr-kdeconnect-fix" { };
  hyprqt6engine = call "hyprqt6engine" { };
  irori = call "irori" { };
  linux-firmware-minimal = call "linux-firmware-minimal" { };
  llama-cpp-inkling = call "llama-cpp-inkling" { };
  matugen-themes = call "matugen-themes" { };
  open-audio-analyzer = call "open-audio-analyzer" { };
  pw-audioshare = rustSlim (call "pw-audioshare" { });
  pycamilladsp = call "pycamilladsp" { };
  pycamilladsp-plot = call "pycamilladsp-plot" { };
  rustgis = call "rustgis" { };
  sola-mpd = call "sola-mpd" { };
  solidcraft = rustSlim (call "solidcraft" { }); # parametric 3D CAD + headless CLI/MCP
  swayimg = call "swayimg" { };
  tewi = call "tewi" { };
  tmd-top = call "tmd-top" { };
  ttf-code2000 = call "ttf-code" { variant = "ttf-code2000"; }; # Code2000 shareware Unicode font (Basic Multilingual Plane)
  ttf-code2001 = call "ttf-code" { variant = "ttf-code2001"; }; # Code2001 freeware font for Plane 1 (historic scripts)
  ttf-code2002 = call "ttf-code" { variant = "ttf-code2002"; }; # Code2002 freeware font for Plane 2 (rare CJK)
  ttf-code20x3 = call "ttf-code" { variant = "ttf-code20x3"; }; # Code20X3 freeware font for Plane 3 (CJK Ext G/H)
}
