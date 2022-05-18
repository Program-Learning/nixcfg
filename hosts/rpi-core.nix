{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  cfgLimit = 10;
in
{
  imports = [
    ../mixins/common.nix
    ../mixins/sshd.nix
    ../mixins/tailscale.nix
    ../mixins/wpa-slim.nix

    # TODO should mixins/tailscale.nix just include this?
    ../modules/tailscale-autoconnect.nix
  ];

  config = {
    boot = {
      # low mem device
      tmpOnTmpfs = lib.mkDefault false;
      cleanTmpDir = lib.mkDefault true;
      loader = {
        grub.enable = lib.mkDefault false;
        generic-extlinux-compatible.enable = lib.mkDefault true;
        generic-extlinux-compatible.configurationLimit = lib.mkDefault cfgLimit;
      };
      # kernelPackages will default to latest from our `mixins/common.nix`
      # kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };

    nix.nixPath = lib.mkDefault [ ];
    nix.gc.automatic = lib.mkDefault true;

    # minimal, even if we dupe across mixins/common.nix
    documentation.enable = lib.mkDefault false;
    documentation.doc.enable = lib.mkDefault false;
    documentation.info.enable = lib.mkDefault false;
    documentation.nixos.enable = lib.mkDefault false;

    networking.firewall.enable = lib.mkDefault true;

    services.fwupd.enable = lib.mkForce false; # doesn't xcompile, don't remember the details

    specialisation = {
      "foundation" = {
        inheritParentConfig = true;
        configuration = {
          config.boot.kernelPackages = pkgs.linuxPackages_rpi4;
        };
      };
    };
  };
}
