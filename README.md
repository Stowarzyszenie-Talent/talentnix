# Talentnix

This repo contains a nix flake with:

- a NixOS module for the "Talentop"s (Talent's laptops used e.g. on camps)
- an installer for the aforementioned system

### Building the ISO

Prerequisites:

- nix with the `nix-command` and `flakes` experimental features
- an internet connection for downloading roughly 1.5GB (usually only for the first build)

Steps:

1. `nix build .#installer-iso` in the repo root
2. The ISO is in result/iso

### Installation

1. Get the ISO
2. Flash it to a pendrive (`dd if=iso.iso of=/dev/sdX` should do the trick)
3. Boot the pendrive. If you don't have ethernet, set wifi up in another tty.
4. Follow the on-screen instructions
     - the hostname ought to be `talentop-XXX` where XXX is the code from a sticker
     - pay attention to the prompt about clearing the user's home
     - enter the root password, which should be known among us (the technical staff)

### Updating

If the nixos release in this repo was changed, then it is preferable to
reinstall from a new ISO in order to avoid large downloads.

Otherwise:

1. Get an internet connection on the talentop
2. `su` to root and `cd /etc/nixos`
3. Run `nix flake update` and `nixos-rebuild switch`
