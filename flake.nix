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
    packages.x86_64-linux.netboot = with self.nixosConfigurations.installer-x86_64-linux.config.system.build; self.nixosConfigurations.installer-x86_64-linux.pkgs.symlinkJoin {
      name = "netboot";
      paths = [
        netbootRamdisk
        kernel
        netbootIpxeScript
      ];
      #postBuild = ''
      #  mkdir -p $out/nix-support
      #  echo "file ${kernelTarget} ${build.kernel}/${kernelTarget}" >> $out/nix-support/hydra-build-products
      #  echo "file initrd ${build.netbootRamdisk}/initrd" >> $out/nix-support/hydra-build-products
      #  echo "file ipxe ${build.netbootIpxeScript}/netboot.ipxe" >> $out/nix-support/hydra-build-products
      #'';
      #preferLocalBuild = true;
    };

  };
}
