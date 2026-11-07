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

edit-secrets file="shared":
	sops secrets/{{ file }}.yaml

sync-secrets:
	for f in secrets/*.yaml; do sops updatekeys -y "$f"; done

deploy machine=`hostname`:
	{{ if machine == `hostname` { 'git add --intent-to-add . && sudo nixos-rebuild switch --accept-flake-config --flake .#' + machine } else { 'echo "Machine does not match current hostname"' } }}

remote-deploy-ara:
	git add --intent-to-add . && nixos-rebuild switch --accept-flake-config --flake .#ara --sudo --ask-elevate-password --target-host ara --build-host ara

build-iso machine:
	git add --intent-to-add . && nix build --accept-flake-config .#nixosConfigurations.{{ machine }}-iso.config.system.build.isoImage
