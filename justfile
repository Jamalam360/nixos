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
	deno run -A .github/workflows/update_fetchers.ts

hash-password:
	read -s -p "Enter password: " password; echo; echo -n "$$password" | mkpasswd -m sha-512 -s

edit-secrets:
	sops secrets/secrets.yaml

sync-secrets:
	sops updatekeys secrets/secrets.yaml

deploy-lyra:
	git add . && nix-shell -p '(nixos{}).nixos-rebuild' --command 'nixos-rebuild switch --accept-flake-config --fast --flake .#lyra --use-remote-sudo --target-host "james@176.9.22.221" --build-host "james@176.9.22.221"'

deploy-hercules:
	git add . && sudo nixos-rebuild switch --accept-flake-config --fast --flake .#hercules 

deploy-leo:
	git add . && sudo nixos-rebuild switch --accept-flake-config --fast --flake .#leo 
