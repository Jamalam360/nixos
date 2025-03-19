{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "Jamalam360";
    repo = "cdn";
    rev = "2790dc48d12889f41be6894d8ef119964f1370cf";
    hash = "sha256-9qXVbqMpZPbos9hH6KRtJqA1HDCRZAIgBvyA31jjdC8=";
  };
in {
  services.nginx.virtualHosts."cdn.jamalam.tech" = {
    enableACME = true;
    forceSSL = true;
    root = src;
  };
}
