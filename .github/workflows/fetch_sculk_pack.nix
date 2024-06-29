{
  pkgs,
  url,
  sculk,
  ...
}:
(sculk.nixFunctions.fetchSculkModpack {
  inherit (pkgs) stdenvNoCC jre_headless;
  sculk = sculk.packages.sculk.x86_64-linux;
}) {
  inherit url;
  hash = pkgs.lib.fakeSha256;
}
