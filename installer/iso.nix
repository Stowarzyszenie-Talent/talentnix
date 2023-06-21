{ config, pkgs, lib, modulesPath, nixpkgs, talentnix, ... }:

let
  partialSystem =
    (nixpkgs.lib.nixosSystem {
      inherit (pkgs) system;
      modules = [
        talentnix.nixosModules.default
        {
          boot.loader.grub.devices = [ "/driveless-shelter" ];
          fileSystems."/" = { device = "/driveless-shelter"; fsType = "ext4"; };
          system.stateVersion = config.system.nixos.release;
        }
      ];
    }).config.system.build.toplevel;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  system.nixos.distroName = "TalentNix";
  system.nixos.distroId = "talentnix";
  isoImage.isoBaseName = "talentnix-installer";
  isoImage.squashfsCompression = "zstd -Xcompression-level 9";

  # This sets up the nix store on the iso to contain most of the packages required for installation so that one can be performed without an internet connection (although this may not always hold true)
  isoImage.storeContents = [ partialSystem ];

  programs.neovim.enable = true;

  programs.bash.loginShellInit = ''
    if [[ $(tty) == /dev/tty1 ]]; then
      talentnix-install || {
        echo -e "\x1b[31;1mInstallation failed!\x1b[0m"
        read -r
        exit 1
      }
      exit
    fi
  '';

  environment.systemPackages =
    let
      path = with pkgs; [
        bash
        nixos-install-tools
        coreutils
        findutils
        parted
        stdenvNoCC
      ];
      installer = pkgs.runCommand "talentnix-installer"
        {
          script = pkgs.substituteAll {
            src = ./install;
            template = ./template;
            this = ./..;
            inherit nixpkgs partialSystem;
            stateVersion = config.system.nixos.release;
          };
          nativeBuildInputs = with pkgs; [ makeWrapper ];
        } ''
        mkdir -p $out/bin
        cp $script $out/bin/talentnix-install
        chmod +x $out/bin/talentnix-install
        wrapProgram $out/bin/talentnix-install \
          --prefix PATH : ${lib.makeBinPath path}
      '';
    in
    with pkgs; [
      git
      htop
      installer
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
