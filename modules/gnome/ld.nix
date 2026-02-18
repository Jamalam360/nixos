{pkgs, ...}: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Required for Prisma
      openssl
      # Required for running Minecraft mods via Gradle
      flite
      libglvnd
      libpulseaudio
      libxkbcommon
      wayland
      libx11
      libxcursor
    ];
  };
}
