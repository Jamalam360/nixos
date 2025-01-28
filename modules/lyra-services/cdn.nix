{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "cd02612bd09bd9cd20478d0bc006ae7267a3e996";
    hash = "sha256-y+XqsoaFws9AUM4D+J48i1dkOGI/yXmjLpE30AMFamQ=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
