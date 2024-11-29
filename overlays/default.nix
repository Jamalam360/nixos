{inputs}: (final: prev: let
  overlays =
    import ./fixes
    ++ [
      (import ../pkgs)
      (import ../scripts)
      (final: prev: {inherit (inputs.sculk.packages.x86_64-linux) sculk;})
    ];
in
  prev.lib.composeManyExtensions overlays final prev)
