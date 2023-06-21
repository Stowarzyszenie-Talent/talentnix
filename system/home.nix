{ pkgs, lib, ... }:

{
  # Lista zmienionych rzeczy:
  # geany: xterm --> xfce4-term; colorscheme'y; -std=c++17 przy kompilacji.
  home.activation.copyGeanyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.gnutar}/bin/tar -xv --skip-old-files -C "$HOME" --owner=user --group=users \
      -f ${./skel.tar}
  '';

  services.network-manager-applet.enable = true;
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Talentnix firefox profile";
      bookmarks = [{
        toolbar = true;
        bookmarks = [
          {
            name = "Obozowe SIO2 - oboz.talent.edu.pl";
            url = "https://oboz.talent.edu.pl";
          }
          {
            name = "Wyzwania";
            url = "https://wyzwania.programuj.edu.pl";
          }
        ];
      }];
      search = {
        default = "DuckDuckGo";
        force = true;
      };
    };
  };

  # To nie działa do końca, bo potrza xfconf poniżej. Można zastąpić package'ami
  gtk = {
    enable = true;
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  xfconf.settings = {
    xsettings = {
      "Net/ThemeName" = "Arc-Dark";
      "Net/IconThemeName" = "Arc";
    };
    xfce4-desktop = builtins.listToAttrs (
      builtins.map
        (x: {
          name = "backdrop/screen0/monitor${x}-1/workspace0/last-image";
          value = "${../assets/wallpaper.png}";
        }) [ "LVDS" "HDMI" "DP" "eDP" "Virtual" ]);
  };

  home.stateVersion = "23.05";
}
