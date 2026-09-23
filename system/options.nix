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
    encrypted = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = lib.mkDoc ''
        Whether root, home and worker are LUKS encrypted with a key derived from the hardware.
      '';
    };
  };
}
