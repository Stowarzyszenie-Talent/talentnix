{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosModules.default = { config, pkgs, ... }: {
      imports = [
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.users.user = import ./system/home.nix;
        }

        ./system/configuration.nix
      ];
    };
    nixosConfigurations.installer-x86_64-linux = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nixpkgs;
        talentnix = self;
      };
      modules = [
        ./installer/iso.nix
      ];
    };
    packages.x86_64-linux.installer-iso = self.nixosConfigurations.installer-x86_64-linux.config.system.build.isoImage;
  };
}
