{pkgs}: let
  script = ''
    flake="$HOME/dev/nixos/devshell-templates/$1.nix"
    if [[ ! -f "$flake" ]]; then
    	echo "$flake not found"
    	exit 1
    fi

    echo "use flake" > ".envrc"
    echo ".direnv/" > ".gitignore"
    cp "$flake" "./flake.nix"
    echo "Run {direnv allow} to activate devshell"
  '';
in
  pkgs.writeShellScriptBin "devshell-init" script
