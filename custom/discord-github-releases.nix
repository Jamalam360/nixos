{ stdenv, lib, makeWrapper, fetchFromGitHub, deno }:

stdenv.mkDerivation rec {
  pname = "discord-github-releases";
  version = "6ab9a84a98c789c021873ca06bfeeea4790a7977";

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-KvtM71EpfjXNWrxWSClfmMTgx0JUNnmlFUxZQ/Pba+0=').";
  };

  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    cp $src/index.ts $out/lib/discord-github-releases.ts
    makeWrapper ${lib.getExe deno} $out/bin/discord-github-releases \
      --set DENO_NO_UPDATE_CHECK "1" \
      --add-flags "run --allow-net --allow-read ${placeholder "out"}/lib/discord-github-releases.ts"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Allows you to send custom Discord messages when a new release is published on GitHub.";
    homepage = "https://github.com/Jamalam360/${pname}";
    license = licenses.mit;
    mainProgram = "${pname}";
  };
}
