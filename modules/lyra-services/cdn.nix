{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "29ed436045829f472d33e45b62c5b53aa615e20b";
    hash = "sha256-0idhQS/YbrJaDIcj9obEzX4TKV5QUkyygp6A/tU1JKc=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
