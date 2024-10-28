{
  inputs,
  pkgs,
}:
inputs.sculk.lib.fetchSculkModpack {
  inherit (pkgs) stdenvNoCC jre_headless sculk;
} {
  url = "https://raw.githubusercontent.com/Jamalam360/pack/75844eefc810b37e13d4a3fa99a60e6114410aef";
  hash = "sha256-mnyDKK+JWRGDL0g00lKYcG7BJB0o2MB3IS3JF4Y363U=";
}
