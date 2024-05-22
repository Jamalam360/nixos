{ stdenv, lib, makeWrapper, fetchFromGitHub, deno }:

stdenv.mkDerivation rec {
  pname = "discord-github-releases";
  version = "cd112fc9720c33f049938ea9797faefabe2c3475";

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-dSOkNp7m1H4LloLsgPPlA7RPo4sP6BL5SxT2AzxzA+M=";
  };

  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
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
