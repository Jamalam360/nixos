{
  pkgs,
  url,
  sculk,
  ...
}:
(sculk.lib.fetchSculkModpack {
  inherit (pkgs) stdenvNoCC jre_headless;
  inherit (sculk.packages."${builtins.currentSystem}") sculk;
}) {
  inherit url;
  hash = pkgs.lib.fakeSha256;
}
