{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "sat-bot";
  version = "38cc4da14671b1d0cc65793f963526fd042f8744";

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-MUhjaQs+FdI30gWfU+cOeKcBtihNuGo2UBVGdJxRd8M=";
  };

  cargoHash = "sha256-fqL0In45oPzC7zVbtBdFHESqbOnhzk34fyu6uNGDX6M";

  meta = with lib; {
    description = "A super quickly made Discord bot that notifies you of satellite passes.";
    homepage = "https://github.com/Jamalam360/${pname}";
    license = licenses.mit;
    mainProgram = "${pname}";
  };
}
