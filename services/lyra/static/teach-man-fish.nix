{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "teach-man-fish";
    rev = "c63ab2c005d31af64f9d780a0965e934bb841f8a";
    hash = "sha256-9hpI2sTLlJ9oxoKVBxmdxVJNi9Ng8cYvNCMwqKrJvio=";
  };
in
{
  services.nginx.virtualHosts."teachmanfish.jamalam.tech" =  {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
