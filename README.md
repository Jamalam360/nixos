# NixOS

This repository holds my Nix configuration, using:

- Flakes,
- [Home Manager](https://github.com/nix-community/home-manager),
- [Sops](https://github.com/Mic92/sops-nix) for managing secrets,
- GitHub Actions to update `flake.lock` daily and linting,
- and Just for aliasing commands.

It contains configuration for 3 machines:

1. Hercules, my Framework laptop.
2. Lyra, my decomissioned Hetzner dedicated server (the configuration is kept for future reference).
3. Leo, my desktop.
4. Ara, my Hetzner VPS.

## Folders

- `devshell-templates` contains example devshells that I can copy into my projects.
- `hosts` contains a `configuration.nix` and `hardware-configuration.nix` for each machine.
- `modules` contains reusable modules used to configure machines.
- `overlays` contains nixpkgs overlays with fixes and custom packages from `pkgs`.
- `pkgs` contains custom derivations.
- `scripts` contains Bash scripts globally available on my systems.
- `secrets` contains secrets encrypted using Sops.

## Adding a New Machine

0. Find a constellation to name the machine after :)
1. Create the base configuration files for the machine (`machines/...`, NixOS module, Home Manager module).
2. Install NixOS and copy `hardware-configuration.nix` to the repo.
3. Import personal SSH and GPG keys.
4. Run the following: 
	- `mkdir -p ~/.config/sops/age`
	- `sudo nix-shell -p ssh-to-age --run "ssh-to-age --private-key -i /etc/ssh/ssh_host_ed25519_key > /home/james/.config/sops/age/keys.txt"`
5. Run `nix-shell -p ssh-to-age --run "cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age"` and add the result to `.sops.yaml`.
6. Run `just sync-secrets`.
7. Add a `deploy-...` task for the new machine in the `justfile`.
8. Clone `git@github.com:Jamalam360/nixos` on the target machine.
9. Run the deploy task.
10. Run `direnv allow` after the deployment.

## Resources and Credits

Where I have used resources for a specific expression, I have included comments pointing back to them; other than that I have used:

- The [Nix Pills](https://nixos.org/guides/nix-pills/) for learning the basics.
- [eh8/chenglab](https://github.com/eh8/chenglab) and [Baitinq/nixos-config](https://github.com/Baitinq/nixos-config) for substantial inspiration on how to structure everything.
- [LGUG2Z/nixos-hetzner-robot-starter](https://github.com/LGUG2Z/nixos-hetzner-robot-starter) for pointers on how to install NixOS on Lyra.
