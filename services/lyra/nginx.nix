{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "james@jamalam.tech";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
