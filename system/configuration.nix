{ pkgs, ... }:

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
  networking.networkmanager.enable = true;

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
      if [[ "$1" == "update" ]]; then
        if [[ $(id -u) -ne 0 ]]; then
            exec su -c "''${BASH_SOURCE[0]} $@" || exit 1
        fi
        cd /etc/nixos
        nix flake lock --update-input talentnix
        nixos-rebuild switch
        exit 0
      fi
      echo -e "Usage:\n   talentctl <subcommand>\n"
      echo -e "Available subcommands:\n - update\n - clear\n - cancel_clear"
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
  ];

  services = {
    openssh.enable = true;
    xserver = {
      enable = true;
      layout = "pl";
      desktopManager.xfce.enable = true;
      displayManager.autoLogin.user = "user";
      xautolock.enable = false;
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
