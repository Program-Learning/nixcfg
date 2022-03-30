{ config, pkgs, modulesPath, ... }:

{
  config = {
    # TODO: fix rfkill instead:
    system.activationScripts.rfkillUnblockWan = {
      text = ''
        (
          set -x
          rfkill unblock wlan
        )
      '';
      deps = [ ];
    };
    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      iwd.enable = false;
      networks = {
        "chimera-iot".pskRaw = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
      };
    };
  };
}
