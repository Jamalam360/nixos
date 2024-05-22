{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "its-clearing-up";
    rev = "e5d4985bf2d6a27483f48af85798c6f6cc2fef63";
    hash = "sha256-ManYHzHP8iBQ1PXLgda74wPNVHYM9BaByGG7JcQBmD8=";
  };
in
{
  services.nginx.virtualHosts."weather.jamalam.tech" =  {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
