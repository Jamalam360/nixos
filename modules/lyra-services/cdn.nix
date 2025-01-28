{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "6ac16250052c6a0026f45dcd079c4b7200733149";
    hash = "sha256-fE6qJHw3BDqJ16GH/eQv+Lfkv9w5Rki43zXpE0pbETU=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
