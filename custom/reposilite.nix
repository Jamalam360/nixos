{ stdenv, makeWrapper, openjdk_17_headless }:

stdenv.mkDerivation {
  pname = "reposilite";
  version = "3.5.12";

  src = builtins.fetchurl {
    url = "https://maven.reposilite.com/releases/com/reposilite/reposilite/${version}/reposilite-${version}-all.jar";
    sha256 = "7e27421e4768403f68ca7b0fa20ab28405db6f2756da8c5a645c7942778e7126";
  };

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    makeWrapper ${openjdk_17_headless}/bin/java $out/bin/reposilite \
      --add-flags "-Xmx40m -jar ${src}" \
      --set JAVA_HOME ${openjdk_17_headless}
    runHook postInstall
  '';
}
