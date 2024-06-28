# NixOS

This repository holds my WIP Nix configuration, using:

- Nix Flakes,
- [Home Manager](https://github.com/nix-community/home-manager),
- [Sops](https://github.com/Mic92/sops-nix) for managing secrets,
- GitHub Actions to update `flake.lock` daily,
- and Just for aliasing commands.

It contains configuration for 2 machines:

1. Hercules, my Framework laptop.
2. Lyra, my Hetzner dedicated server.

## Folders

- `custom` contains custom derivations.
- `machines` contains a `configuration.nix` and `hardware-configuration.nix` for each machine.
- `modules` contains reusable modules used to configure machines.
- `secrets` contains secrets encrypted using Sops.
- `services` contains configs for services (primarily used by Lyra).

## Machines

### Lyra

- Important folders on Lyra are backed up to a Backblaze S3 bucket via Restic.

#### Services

- **Nginx** - Reverse proxy.
- **Reposilite** - Maven server.
- **Sat Bot** - Discord bot.
- **Discord GitHub Releases** - Discord bot.
- **It's Clearing Up** - Static website.
- **Teach Man Fish** - Static website.
- **Minecraft Server**

## Resources and Credits

Where I have used resources for a specific expression, I have included comments pointing back to them; other than that I have used:

- The [Nix Pills](https://nixos.org/guides/nix-pills/) for learning the basics.
- [eh8/chenglab](https://github.com/eh8/chenglab) for substantial inspiration on how to structure everything.
- [LGUG2Z/nixos-hetzner-robot-starter](https://github.com/LGUG2Z/nixos-hetzner-robot-starter) for pointers on how to install NixOS on Lyra.
