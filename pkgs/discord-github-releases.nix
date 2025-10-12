{
  stdenv,
  lib,
  makeWrapper,
  fetchFromGitHub,
  deno,
}:
stdenv.mkDerivation rec {
  pname = "discord-github-releases";
  version = "acfab742ab27edc86813347154c977848133917b";

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "acfab742ab27edc86813347154c977848133917b";
    hash = "sha256-88nYD9SbZGE64D7/qZe4DZCuHVU9XfQzwIowWr5eR64=";
  };

  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp $src/index.ts $out/lib/discord-github-releases.ts
    makeWrapper ${lib.getExe deno} $out/bin/discord-github-releases \
      --set DENO_NO_UPDATE_CHECK "1" \
      --add-flags "run --allow-net --allow-env --allow-read ${placeholder "out"}/lib/discord-github-releases.ts"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Allows you to send custom Discord messages when a new release is published on GitHub.";
    homepage = "https://github.com/Jamalam360/${pname}";
    license = licenses.mit;
    mainProgram = "${pname}";
  };
}
