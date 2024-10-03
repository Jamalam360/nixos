{
  lib,
  fetchFromGitHub,
  pkgs
}:
pkgs.buildGoModule rec {
  pname = "pinguino-quotes";
  version = "098b6b2f81e00a5f694264e7881205093cf429b8";
  vendorHash = "sha256-IsQnPPvMA6UivA7XCoR/FxOp9+l5KYdhz09hA0ccrZY=";

  buildInputs = [
    pkgs.sqlite
  ];

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-MNXe94W/fJF/KQWt1B2xLD+SMybfxYN0G4NtirMt3yI=";
  };

  meta = with lib; {
    description = "A Discord quote recording bot";
    homepage = "https://github.com/Jamalam360/${pname}";
    license = licenses.mit;
    mainProgram = "${pname}";
  };
}
