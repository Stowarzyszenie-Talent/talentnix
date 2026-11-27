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
     - if prompted, enter the GRUB password and the Linux root password from the `talentopy/root-install` entry in TalentPass

Installation requires a writable disk of at least 32 GiB and replaces its partition table. The installer uses `systemd-repart` to size `/`, `/home`, `/worker` and swap according to the disk capacity, with at least 24 GiB for `/`. The BIOS boot and EFI partitions have fixed sizes.

The installer reads per-host settings from `/config/<MAC>` and the hostname from `/hostname/<MAC>` under the Flash base URL. The base is `https://flash.talent.edu.pl/talentnix` on `master` and `https://flash.talent.edu.pl/oinix` on `oi`.

To fetch password hashes automatically, set `SET_GRUB_PWD=true` with `GRUB_PWD_FILE`, and `SET_ROOT_PWD=true` with `ROOT_PWD_FILE`, in the per-host configuration. Both files must be served over HTTPS and contain one line. The GRUB file takes a `grub-mkpasswd-pbkdf2` hash, and the root file takes a yescrypt or SHA-512 crypt hash. The installer prompts for a password if automatic fetching is disabled, the URL is missing, the download fails, or the hash is invalid. Both hashes are stored under `/var/lib/talentnix` on the installed system.

### Updating

If the nixos release in this repo was changed, then it is preferable to
reinstall from a new ISO in order to avoid large downloads.

Otherwise:

1. Get an internet connection on the talentop
2. `su` to root and `cd /etc/nixos`
3. Run `nix flake lock --update-input talentnix` and `nixos-rebuild switch`
