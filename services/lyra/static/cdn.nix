{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "12519bc1f3d204ad8f1899c6aa9f3c3769b4d7cb";
    hash = "sha256-bFr0lEd3A61YMTRRw93QjPVTht8bOyK/1wfSViJ1CBQ=";
  };
in
{
  services.nginx.virtualHosts."cdn.jamalam.tech" =  {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
