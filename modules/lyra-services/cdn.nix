{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "878a763a0a2e4ca809f24fe593b8086b26670604";
    hash = "sha256-gfd07Hf9G/wyrNPQk76wYU8cMsHxGI8CZCL4JhlHmbk=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
