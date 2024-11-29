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

    fabric_jar=$(ls fabric/build/libs/*.jar | sed -n "2p;")
    neoforge_jar=$(ls neoforge/build/libs/*.jar | sed -n "2p;")
    echo "Fabric jar: $fabric_jar"
    echo "Neoforge jar: $neoforge_jar"

    cp "$fabric_jar" "$HOME/.local/share/PrismLauncher/instances/Fabric - $minecraft_version/.minecraft/mods" || exit 1
    cp "$neoforge_jar" "$HOME/.local/share/PrismLauncher/instances/Neoforge - $minecraft_version/.minecraft/mods" || exit 1

    echo "Copied to Prism"
  '';
in
  pkgs.writeShellScriptBin "copy-artifacts-to-prism" script
