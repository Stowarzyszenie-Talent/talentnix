{
  # This is a specific hash in 23.05 to avoid building stuff like firefox,
  # since hydra didn't do that yet as of when I'm writing this.
  # Should be reverted to 23.05 someday.
  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs?rev=2283bf968f3b6a2f100d81fb43db6d91f6aea706";
  };
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
        inherit nixpkgs home-manager;
        talentnix = self;
      };
      modules = [
        ./installer/iso.nix
      ];
    };
    packages.x86_64-linux.installer-iso = self.nixosConfigurations.installer-x86_64-linux.config.system.build.isoImage;
  };
}
