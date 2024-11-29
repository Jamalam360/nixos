{
  lib,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "sat-bot";
  version = "6a68ddcd478ae52f3dce8d0fd66852fd1d200b27";

  src = fetchFromGitHub {
    owner = "Jamalam360";
    repo = "${pname}";
    rev = "6a68ddcd478ae52f3dce8d0fd66852fd1d200b27";
    hash = "sha256-UTBrIp9Iz/dgc/65uoyJcPw8GcGRu8Cn/ISxLn+gxPU=";
  };

  cargoHash = "sha256-yVpeFQC6lZIWxXhvwGMAfRllDTIlinxv3mHqafvcLNU=";

  buildInputs = [openssl];
  nativeBuildInputs = [pkg-config];

  meta = with lib; {
    description = "A super quickly made Discord bot that notifies you of satellite passes.";
    homepage = "https://github.com/Jamalam360/${pname}";
    license = licenses.mit;
    mainProgram = "${pname}";
  };
}
