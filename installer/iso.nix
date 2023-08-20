{ system, config, pkgs, lib, modulesPath, nixpkgs, talentnix, home-manager, ... }:

let
  partialSystem =
    (nixpkgs.lib.nixosSystem {
      inherit (pkgs) system;
      modules = [
        talentnix.nixosModules.default
        {
          boot.loader.grub.devices = [ "/driveless-shelter" ];
          environment.systemPackages = with pkgs; [ grub2 ];
          fileSystems."/" = { device = "/driveless-shelter"; fsType = "ext4"; };
          system.stateVersion = config.system.nixos.release;
        }
      ];
    });#.config.system.build.toplevel;
  tarballs = lib.getTarballs {
    root = [ partialSystem.config.system.build.toplevel partialSystem.config.environment.systemPackages ];
    includeUnzipped=true;
    includeBusybox=true;
  };
  tarballsList = pkgs.writeText "tarballs-list" (builtins.concatStringsSep "\n" tarballs);
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    (import ./nixos-installer-gen/tarballServer.nix {
      inherit system nixpkgs;
      includeBusybox=true;
      config = partialSystem.config;
    })
    (import ./nixos-installer-gen/genSymlinks.nix {
      inherit tarballs lib;
    })
  ];

  system.extraDependencies = [ tarballsList ];
  system.nixos.distroName = "TalentNix";
  system.nixos.distroId = "talentnix";
  isoImage.isoBaseName = "talentnix-installer";
  isoImage.squashfsCompression = "zstd -Xcompression-level 9";

  # This sets up the nix store on the iso to contain most of the packages required for installation so that one can be performed without an internet connection (although this may not always hold true)
  isoImage.storeContents = [ partialSystem.config.system.build.toplevel ];

  # Serve the rest like https://tarballs.nixos.org or sth

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
            inherit nixpkgs;
            partialSystem = partialSystem.config.system.build.toplevel;
            hm = home-manager;
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

  # Needed for eebfe989a5dc3aac622b9b5f2edef4461d8968c1,
  # which fixes our offline installation.
  nix.package = pkgs.nixVersions.nix_2_17;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
