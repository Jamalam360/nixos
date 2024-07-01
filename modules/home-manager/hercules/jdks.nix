# inspo: https://discourse.nixos.org/t/fix-collision-with-multiple-jdks/10812/5
{ pkgs, ... }:

let
  additionalJDKs = with pkgs; [ temurin-bin-17 temurin-bin-21 ];
in
{
  programs.java = {
    enable = true;
    # This determines JAVA_HOME - set to Java 21 at the moment as that is what modern Minecraft uses
    package = pkgs.temurin-bin-21;
  };

  home.sessionPath = [ "$HOME/.jdks" ];
  home.file = (builtins.listToAttrs (builtins.map (jdk: {
    name = ".jdks/${jdk.version}";
    value = { source = jdk; };
  }) additionalJDKs));
}