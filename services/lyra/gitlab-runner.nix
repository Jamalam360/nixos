{
  config,
  ...
}: {
  virtualisation.docker.enable = true;
  services.gitlab-runner = {
    enable = true;
    services.default = {
      # File should contain at least these two variables:
      # `CI_SERVER_URL`
      # `CI_SERVER_TOKEN`
      authenticationTokenConfigFile = config.sops.secrets."gitlab-runner-token".path;
      dockerImage = "debian:stable";
    };
  };
}