{ pkgs, lib, config, ... }:

{
  # Silent boot
  boot.loader.grub = {
    splashImage = null;
    extraConfig = ''
      timeout_style=hidden
    '';
  };
  boot.loader.timeout = 1;
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" "udev.log_level=3" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Warsaw";

  networking.networkmanager.enable = config.talent.wifiLock == "";
  networking.wireless = lib.mkIf (config.talent.wifiLock != "") {
    enable = true;
    # Currently broken, see https://github.com/NixOS/nixpkgs/issues/157537
    #allowAuxiliaryImperativeNetworks = true;
    networks = {
      "${config.talent.wifiLock}" = {
        psk = "1234567890";
      };
    };
  };

  users.users.user = {
    isNormalUser = true;
    password = "user";
    extraGroups = [ "networkmanager" ];
  };

  environment.systemPackages = with pkgs;
  let
    update = writers.writeBashBin "talentctl" ''
      set -e
      if [[ "$1" == "clear" ]]; then
        touch /home/user/clear_home
        echo "A clear was scheduled, it will happen on the next boot."
        exit 0
      fi
      if [[ "$1" == "cancel_clear" ]]; then
        if [[ -e /home/user/clear_home ]]; then
          rm /home/user/clear_home || exit 2
          echo "Clear canceled."
          exit 0
        else
          echo "No clear was scheduled."
          exit 3
        fi
      fi
      if [[ "$1" == "wifiLock" ]]; then
        if [[ $(id -u) -ne 0 ]]; then
            exec su -c "''${BASH_SOURCE[0]} $@" || exit 1
        fi
        val='"'"''${2:-}"'"'
        if [[ "$val" == '""' ]]; then
            echo -e "Removing the wifi lock\n"
        else
            echo -e "Setting the wifi lock to $val\n"
        fi
        sed -i "s/talent.wifiLock =.*$/talent.wifiLock = ''${val};/" /etc/nixos/flake.nix
        nixos-rebuild switch
        exit 0
      fi
      if [[ "$1" == "update" ]]; then
        if [[ $(id -u) -ne 0 ]]; then
            exec su -c "''${BASH_SOURCE[0]} $@" || exit 1
        fi
        cd /etc/nixos
        nix flake lock --update-input talentnix
        nixos-rebuild switch
        exit 0
      fi
      echo -e "Usage:\n   talentctl <subcommand> ...\n"
      echo -e "Available subcommands:\n - update\n - clear\n - cancel_clear\n - wifiLock [SSID]\n"
    '';
  in
  [
    # our own stuff
    update
    # monitoring stuff
    htop iotop hdparm
    # utils
    zsh exa fzf ripgrep libarchive curl wget
    # ides and text editors
    codeblocks emacs geany nano neovim xfce.mousepad vim-full
    # other dev stuff
    glibc.static gcc gdb valgrind git
    # calculators
    python3 bc gnome.gnome-calculator
    unzip
  ];

  services = {
    openssh = {
      enable = true;
      settings = {
        AllowUsers = "root";
        PermitRootLogin = "yes";
      };
    };
    xserver = {
      enable = true;
      layout = "pl";
      desktopManager.xfce.enable = true;
      displayManager.autoLogin.user = "user";
      xautolock.enable = false;
    };
    tlp = {
      enable = true;
      settings = {
        DISK_SPINDOWN_TIMEOUT_ON_AC = "0 0";
        DISK_SPINDOWN_TIMEOUT_ON_BAT = "0 0";
        #DISK_APM_LEVEL_ON_BAT = "254 254";
      };
    };
  };

  systemd.services.clear-home = {
    script = ''
      [[ -e /etc/clear_home_always || -e /home/user/clear_home ]] &&
        ${pkgs.coreutils}/bin/rm -rf /home/user/{*,.*}
      exit 0
    '';
    before = [ "home-manager-user.service" "multi-user.target" "graphical.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
    };
  };
}
