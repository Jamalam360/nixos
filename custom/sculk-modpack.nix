# inspo: https://github.com/Infinidoge/nix-minecraft/blob/master/pkgs/tools/fetchPackwizModpack/default.nix
{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
  jre_headless,
}: let
  fetchSculkModpack = {
    pname ? "sculk-modpack",
    version ? "",
    modpackOwner,
    modpackRepo,
    modpackRev,
    modpackHash,
    derivationHash,
    side ? "server",
    ...
  } @ args:
    stdenvNoCC.mkDerivation (finalAttrs:
      {
        inherit pname version;

        sculk = fetchurl rec {
          pname = "sculk";
          version = "0.1.0+beta.6";
          url = "https://github.com/sculk-cli/${pname}/releases/download/${version}/${pname}-${version}.jar";
          hash = "sha256-ThnBZ+36VOwktM10bsG01QSov/0Tui4u1oT1B1lJpTw=";
        };

        modpack = fetchFromGitHub {
          owner = modpackOwner;
          repo = modpackRepo;
          rev = modpackRev;
          sha256 = modpackHash;
        };

        dontUnpack = true;
        dontFixup = true;

        buildInputs = [jre_headless];

        buildPhase = ''
          runHook preBuild
          java -jar $sculk install --side ${side} $modpack
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          rm env-vars -r
          mkdir -p $out
          cp -r * $out/
          runHook postInstall
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = derivationHash;
      }
      // args);
in
  fetchSculkModpack
