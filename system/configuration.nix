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

  environment.systemPackages = with pkgs; [
    htop
    iotop
    hdparm
    zsh
    exa
    fzf
    libarchive
    gnome.gnome-calculator
    firefox
    codeblocks
    emacs
    geany
    nano
    neovim
    xfce.mousepad
    vim-full
    git
    glibc.static
    gcc
    gdb
    valgrind
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
