{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "d470dd59c3ef261e6b09da243b143c5ed4c4b2ff";
    hash = "sha256-lKBfhvetbuba9hA8mI69qPQnJ2H1/2FQE76xqLtTyV8=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
