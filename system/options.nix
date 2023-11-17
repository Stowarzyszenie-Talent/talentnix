{ pkgs, lib, config, ... }:

{
  options.talent = {
    wifiLock = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = lib.mkDoc ''
        Either the SSID of the wifi to lock to or "" for enabling networkmanager.
      '';
    };
  };
}
