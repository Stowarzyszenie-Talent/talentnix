{
  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs/release-25.05";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosModules.default = {
      imports = [
        home-manager.nixosModules.home-manager
        ./system/options.nix
        ./system/configuration.nix
        ./system/home.nix
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
