{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      history
      playlistIcons
      playNext
      savePlaylists
      showQueueDuration
      volumePercentage
    ];
    enabledCustomApps = with spicePkgs.apps; [
      lyricsPlus
    ];

    # theme = spicePkgs.themes.catppuccin;
    # colorScheme = lib.mkForce (lib.mkIf systemConfig.stylix.polarity == "dark" "macchiato" "mocha");
  };
}
