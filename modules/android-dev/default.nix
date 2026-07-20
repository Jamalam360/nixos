{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    android-studio
    android-tools
  ];

  users.users.james.extraGroups = ["adbusers"];
}
