{pkgs, inputs}: 
inputs.sculk.lib.fetchSculkModpack {
        inherit (pkgs) stdenvNoCC jre_headless;
        inherit (inputs.sculk.packages.x86_64-linux) sculk;
      } {
        url = "https://raw.githubusercontent.com/Jamalam360/pack/75844eefc810b37e13d4a3fa99a60e6114410aef";
        hash = "sha256-mnyDKK+JWRGDL0g00lKYcG7BJB0o2MB3IS3JF4Y363U=";
      }