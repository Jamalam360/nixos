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
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };

    emoji = {
      package = pkgs.twitter-color-emoji;
      name = "Twitter Color Emoji";
    };
  };
}
