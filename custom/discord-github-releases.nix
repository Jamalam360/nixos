{ stdenv, lib, makeWrapper, fetchFromGitHub, deno }:

stdenv.mkDerivation rec {
  pname = "discord-github-releases";
  version = "99d58586ac97c8f591fe7a8f9d6972f795d4e9b5";

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-AnryICKLJGOmZK770q1gp1tDB091GOYPHFpg9h3id4E=";
  };

  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    makeWrapper ${deno}/bin/deno $out/index.ts \
      --add-flags "--allow-net --allow-read"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Allows you to send custom Discord messages when a new release is published on GitHub.";
    homepage = "https://github.com/Jamalam360/${pname}";
    license = licenses.mit;
    mainProgram = "${pname}";
  };
}
