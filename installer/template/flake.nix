{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
  inputs.talentnix = {
    url = "github:Stowarzyszenie-Talent/talentnix/oi";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-namager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, talentnix, ... }: {
    nixosConfigurations."&hostname&" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ({ lib, ... }: {
          networking.hostName = "&hostname&";
          boot.loader.grub.devices = [ "&install_device&" ];
          boot.loader.grub.users.root.hashedPassword = lib.mkForce null;
          boot.loader.grub.users.root.hashedPasswordFile = "/var/lib/talentnix/grubPassword";
          users.users.root.hashedPasswordFile = lib.mkForce "/var/lib/talentnix/rootPassword";
          system.stateVersion = "&_stateVersion&";
          talent.wifiLock = "&wifiLock&";
        })
        talentnix.nixosModules.default
      ];
    };
  };
}
