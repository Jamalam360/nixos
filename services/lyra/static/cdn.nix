{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "ce65a750c1602ae687d38f2f010c2bc28c93905e";
    hash = "sha256-AwqqQTtbuXujiD1pn3R/LMRgh0whmkFUjT04r4rbMjk=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
