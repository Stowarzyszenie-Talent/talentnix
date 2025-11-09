{ pkgs, lib, config, ... }:

{
  home-manager.useGlobalPkgs = true;
  # For lib.hm
  home-manager.users.user = {lib, ...}: {
    # Lista zmienionych rzeczy:
    # geany: xterm --> xfce4-term; colorscheme'y; -std=c++17 przy kompilacji.
    home.activation.copyGeanyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.gnutar}/bin/tar -xv --skip-old-files -C "$HOME" --owner=user --group=users \
        -f ${./skel.tar}
    '';

    services.network-manager-applet.enable = config.talent.wifiLock == "";
    programs.firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        name = "Talentnix firefox profile";
        # This will delete all previous bookmarks. Unfortunate.
        bookmarks.force = true;
        bookmarks.settings = [{
          toolbar = true;
          bookmarks = [
            {
              name = "Obozowe SIO2";
              url = "https://oboz.talent.edu.pl";
            }
            {
              name = "Wyzwania";
              url = "https://wyzwania.programuj.edu.pl";
            }
          ];
        }];
        search = {
          default = "ddg";
          force = true;
        };
      };
    };

    # Nowe laptopy nie beda sie gotowaly z VSC
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        formulahendry.code-runner
      ];
      profiles.default.userSettings = {
        "workbench.startupEditor" = "none";
        "workbench.tips.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "jupyter.enabled" = false;
        "files.defaultLanguage" = "cpp";
        "update.mode" = "none";
        "update.enableWindowsBackgroundUpdates" = false;
        "update.showReleaseNotes" = false;
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;
        "extensions.ignoreRecommendations" = true;

        "github.copilot.enable" = false;

        "C_Cpp.default.cppStandard" = "c++23";
        "C_Cpp.default.cStandard" = "c17";

        "code-runner.runInTerminal" = true;
        "code-runner.saveAllFilesBeforeRun" = true;
        "code-runner.executorMap" = {
          "cpp" = "g++ -std=c++23 -Wall -Wextra -O3 -g $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt";
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
      xfce4-power-manager = {
        "xfce4-power-manager/lid-action-on-ac" = 1;
        "xfce4-power-manager/lid-action-on-battery" = 1;
        "xfce4-power-manager/logind-handle-lid-switch" = false;
        "xfce4-power-manager/lock-screen-suspend-hibernate" = false;
      };
      xfce4-screensaver = {
        "lock/enabled" = false;
      };
      xfce4-desktop = builtins.listToAttrs (
        builtins.map
          (x: {
            name = "backdrop/screen0/monitor${x}-1/workspace0/last-image";
            value = "${../assets/wallpaper.png}";
          }) [ "LVDS" "HDMI" "DP" "eDP" "Virtual" ]);
    };

    home.stateVersion = "25.05";
  };
}
