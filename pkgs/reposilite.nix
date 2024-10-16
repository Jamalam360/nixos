{
  stdenv,
  lib,
  makeWrapper,
  openjdk17_headless,
}:
stdenv.mkDerivation rec {
  pname = "reposilite";
  version = "3.5.12";

  src = builtins.fetchurl {
    url = "https://maven.reposilite.com/releases/com/reposilite/reposilite/${version}/reposilite-${version}-all.jar";
    sha256 = "7e27421e4768403f68ca7b0fa20ab28405db6f2756da8c5a645c7942778e7126";
  };

  dontUnpack = true;
  nativeBuildInputs = [makeWrapper];
  installPhase = ''
    runHook preInstall
    makeWrapper ${openjdk17_headless}/bin/java $out/bin/reposilite \
      --add-flags "-Xmx40m -jar ${src}" \
      --set JAVA_HOME ${openjdk17_headless}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Lightweight and easy-to-use repository management software dedicated for the Maven based artifacts in the JVM ecosystem 📦";
    homepage = "https://reposilite.com/";
    license = licenses.asl20;
    mainProgram = "reposilite";
  };
}
