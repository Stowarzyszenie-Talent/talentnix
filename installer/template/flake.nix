{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.talentnix = {
    url = "github:Stowarzyszenie-Talent/talentnix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-namager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, talentnix, ... }: {
    nixosConfigurations."@hostname@" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        {
          networking.hostName = "@hostname@";
          boot.loader.grub.devices = [ "@install_device@" ];
          system.stateVersion = "@_stateVersion@";
        }
        talentnix.nixosModules.default
      ];
    };
  };
}
