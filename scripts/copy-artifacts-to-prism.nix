{pkgs}: let
  script = ''
    if [[ ! -f build.gradle ]]; then
    	echo "build.gradle not found in the current directory"
    	exit 1
    fi

    rm -rf fabric/build/libs/*
    rm -rf neoforge/build/libs/*
    ./gradlew fabric:build neoforge:build || exit 1
    minecraft_version=$(grep -oP "^minecraft_version=.+" gradle.properties | cut -d '=' -f 2)
    echo "Minecraft version: $minecraft_version"

    if [[ $minecraft_version == 1* ]]; then
      echo "Pre-26 Minecraft version detected, using old build output naming convention"
      fabric_jar=$(ls fabric/build/libs/*.jar | sed -n "2p;")
      neoforge_jar=$(ls neoforge/build/libs/*.jar | sed -n "2p;")
    else
      echo "Post-26 Minecraft version detected, using new build output naming convention"
      fabric_jar=$(ls fabric/build/libs/*.jar | sed -n "1p;")
      neoforge_jar=$(ls neoforge/build/libs/*.jar | sed -n "1p;")
    fi

    fabric_dst="$HOME/.local/share/PrismLauncher/instances/Fabric - $minecraft_version/minecraft/mods"
    neoforge_dst="$HOME/.local/share/PrismLauncher/instances/Neoforge - $minecraft_version/minecraft/mods"

    mkdir -p "$fabric_dst" || exit 1
    mkdir -p "$neoforge_dst" || exit 1
    echo "Fabric jar: $fabric_jar --> $fabric_dst"
    echo "Neoforge jar: $neoforge_jar --> $neoforge_dst"
    cp "$fabric_jar" "$fabric_dst" || exit 1
    cp "$neoforge_jar" "$neoforge_dst" || exit 1
    echo "Copied to Prism"
  '';
in
  pkgs.writeShellScriptBin "copy-artifacts-to-prism" script
