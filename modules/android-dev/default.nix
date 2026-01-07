{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    android-studio-full
    android-tools
  ];

  users.users.james.extraGroups = ["adbusers"];
}
