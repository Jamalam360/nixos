{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    android-studio-full
  ];

  programs.adb.enable = true;
  users.users.james.extraGroups = ["adbusers"];
}
