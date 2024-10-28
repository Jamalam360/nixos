{
  pkgs,
  inputs,
}:
inputs.sculk.lib.fetchSculkModpack {
  inherit (pkgs) stdenvNoCC jre_headless;
  inherit (inputs.sculk.packages.x86_64-linux) sculk;
} {
  url = "https://raw.githubusercontent.com/Jamalam360/vanilla-server/88e198103812722496c9719e0851f9b4f48821a6";
  hash = "sha256-fcfOuYuirAcFI1W+1PE3lOBruHtilDDStycsmWPGHKQ=";
}
