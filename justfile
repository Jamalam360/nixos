default:
	just --list

update:
	nix --extra-experimental-features 'flakes nix-command' flake update
