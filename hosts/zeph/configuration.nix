{ config, pkgs, lib, inputs, ... }:

let
  hn = "zeph";
  poolname = "zephpool";
  bootpart = "zeph-boot";
  swappart = "zeph-swap";
  lukspart = "zeph-luksroot";
in
{
  imports = [
    ../../profiles/gui-sway.nix
    ../../profiles/gui-i3.nix

    ../../profiles/addon-asus.nix
    ../../profiles/addon-gaming.nix
    ../../profiles/addon-laptop.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/libvirtd.nix
    ../../mixins/syncthing.nix

    ./zrepl.nix # TODO: make this device specific

    # ../../mixins/oavm-risky.nix

    # ./experimental.nix
    ./unfree.nix

    inputs.lanzaboote.nixosModules.lanzaboote

    inputs.nixos-hardware.nixosModules.common-hidpi
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
  ];
  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "23.11";

    networking.hostName = hn;
    # nixcfg.common.hostColor = "#c17ecc"; # tango magenta
    nixcfg.common.hostColor = "magenta";
    nixcfg.common.skipMitigations = true;
    nixcfg.common.defaultKernel = true;
    nixcfg.common.kernelPatchHDR = true;
    nixcfg.common.addLegacyboot = false;

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    services.zfs.autoScrub.pools = [ poolname ];
    fileSystems = {
      "/efi" = { fsType = "vfat"; device = "/dev/nvme0n1p1"; neededForBoot = true; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${bootpart}"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${poolname}/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${poolname}/nix"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${poolname}/home"; neededForBoot = true; };

      "/zfsin" = { fsType = "zfs"; device = "zfsin"; neededForBoot = true; };

      "/var/lib/containers/storage" = { fsType = "zfs"; device = "${poolname}/podman"; };

      "/mnt/data/t5" = { fsType = "zfs"; device = "${poolname}/data/t5"; };

      "/efi/EFI/Linux" = { device = "/boot/EFI/Linux"; options = [ "bind" ]; };
      "/efi/EFI/nixos" = { device = "/boot/EFI/nixos"; options = [ "bind" ]; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/${swappart}"; }];

    home-manager.users.cole = { pkgs, config, ... }@hm: {
      wayland.windowManager.sway.config = {
        keybindings = {
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +2";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -2";
          "XF86AudioMicMute" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
          "XF86Launch1" = "exec ${pkgs.asusctl}/bin/rog-control-center";
          "Mod4+XF86Launch1" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";
        };
      };
    };

    # networking.wireless.iwd.settings = {
    #   General = {
    #     AddressRandomization = "disabled";
    #   };
    # };

    boot = {
      # zfs = {
      #   forceImportAll = true;
      #   extraPools = [ "zfsin" ];
      # };
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
        configurationLimit = 5;
      };
      loader = {
        efi.efiSysMountPoint = "/efi";
        systemd-boot = {
          enable = lib.mkForce (config.boot.lanzaboote.enable != true);
          configurationLimit = lib.mkForce 3;
        };
      };
      kernelModules = [
        "iwlwifi"
        "iwlmvm"
        "mac80211"
        "cfg80211"
        "ptp"
        "asus_wmi"
        "hid_asus"
      ];
      # extraModprobeConfig = ''
      #   options iwlwifi power_save=0
      #   options iwlmvm power_scheme=1
      # '';
      kernelParams = [
        # "zfs.zfs_arc_max=${builtins.toString (1023 * 1024 * (1024 * 6))}"
      ];
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "usbnet"
        "amdgpu"
        "spl" # try to fix systemd-udev-settle issue
        "zfs" # try to fix systemd-udev-settle issue
      ];
      initrd.luks.devices."nixos-luksroot" = {
        device = "/dev/disk/by-partlabel/${lukspart}";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };
}
