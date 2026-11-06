{config, ...}: {
  sops.secrets.gitlab-runner-token = {};
  virtualisation.docker.enable = true;
  services.gitlab-runner = {
    enable = true;
    services.default = {
      authenticationTokenConfigFile = config.sops.secrets."gitlab-runner-token".path;
      dockerImage = "debian:stable";
    };
  };
}
