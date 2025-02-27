{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.nixosModules.stylix];

  stylix.enable = true;
  stylix.fonts = {
    serif = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
    };

    sansSerif = {
      package = pkgs.cantarell-fonts;
      name = "Cantarell";
    };

    monospace = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };

    emoji = {
      package = pkgs.twitter-color-emoji;
      name = "Twitter Color Emoji";
    };
  };
}
