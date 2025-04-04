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

deploy machine:
	git add . && {{ if machine != "lyra" { "sudo" } else { "" } }} nixos-rebuild switch --accept-flake-config --fast --flake .#{{ machine }} {{ if machine == "lyra" { "--use-remote-sudo --target-host \"james@176.9.22.221\" --build-host \"james@176.9.22.221\"" } else { "" } }}

build-iso machine:
	git add . && nix build --accept-flake-config .#nixosConfigurations.{{ machine }}-iso.config.system.build.isoImage
