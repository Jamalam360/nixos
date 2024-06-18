{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "f04f5dc1738905a859febeee1edaf7364605edb0";
    hash = "sha256-L9w6LNYDTM6gGSfnnt4AmuHSowDjUOcIVTddNCP4P+g=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
