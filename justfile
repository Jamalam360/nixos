default:
	just --list

fmt:
	nix fmt .

lint:
	statix check .

fix-lint:
	statix fix .

update:
	nix --extra-experimental-features 'flakes nix-command' --accept-flake-config flake update

update-fetchers:
	.github/workflows/update.sh

hash-password:
	read -s -p "Enter password: " password; echo; echo -n "$$password" | mkpasswd -m sha-512 -s

edit-secrets:
	sops secrets/secrets.yaml

sync-secrets:
	sops updatekeys secrets/secrets.yaml

deploy machine=`hostname`:
	{{ if machine == `hostname` { 'git add . && sudo nixos-rebuild switch --accept-flake-config --flake .#' + machine } else { 'echo "Machine does not match current hostname"' } }}

remote-deploy machine:
	git add . && nixos-rebuild switch --accept-flake-config --flake .#{{ machine }} --sudo --target-host "james@{{ if machine == "ara" { "46.62.221.196" } else { "" } }}" --build-host "james@{{ if machine == "ara" { "46.62.221.196" } else { "" } }}"

build-iso machine:
	git add . && nix build --accept-flake-config .#nixosConfigurations.{{ machine }}-iso.config.system.build.isoImage
