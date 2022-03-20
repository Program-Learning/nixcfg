{ config, lib, pkgs, modulesPath, inputs, ... }:

let
  porty_usb_if = "enp11s0f3u4u4";
in
{
  imports = [
   ../../profiles/sway

    ../../modules/loginctl-linger.nix
    ../../modules/other-arch-vm.nix

    ../../mixins/gfx-nvidia.nix

    ../../mixins/android.nix
    #../../mixins/code-server.nix
    ../../mixins/devshells.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/plex-mpv.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/zfs.nix

    ./grub-shim.nix
  ];

  config = {
    # it sometimes boots as a hyper-v guest, so...
    virtualisation.hypervGuest.enable = true;
      
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11" "nvidia-settings" "cudatoolkit"
      # "memtest86-efi" # pcmemtest instead
    ];

    services.buildVMs =
      let build_config = { imports = [
          ../../profiles/user.nix
      ]; }; in
      {
        # "army" = {
        #   vmSystem = "armv6l-linux";
        #   crossSystem = pkgs.lib.systems.examples.raspberryPi;
        #   cpu = "arm1176";
        #   machine = "versatilepb";
        #   smp = 1;
        #   mem = "256M";
        #   sshListenPort = 2223;
        #   kvm = false;
        #   vmpkgs = inputs.nixpkgs;
        #   config = build_config;
        #   autostart = false;
        # };
        "rusky" = {
          vmSystem = "riscv64-linux";
          crossSystem = pkgs.lib.systems.examples.riscv64;
          smp = 4;
          mem = "8G";
          sshListenPort = 2222;
          kvm = false;
          vmpkgs = inputs.riscvpkgs;
          config = build_config;
        };
      };

    environment.systemPackages = with pkgs; [
      hdparm
      esphome
      mokutil
    ];

    users.users.cole.linger = true;

    boot = {
      supportedFilesystems = [ "zfs" ];
      kernelParams = [ "mitigations=off" ];
    };

    nix.nixPath = [ ];

    hardware.usbWwan.enable = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    networking.hostName = "porty"; # Define your hostname.
    networking.hostId = "abbadaba";
    networking.firewall.allowedTCPPorts = [ 4444 ];

    networking.useDHCP = false;
    networking.interfaces."eth0".useDHCP = true;

    # TODO: only enable when natively booted and working on mobile-nixos, otherwise quite a pain to wait at boot
    # networking.interfaces."enp9s0f3u2u1".ipv4.addresses = [{
    #   address = "10.99.0.1";
    #   prefixLength = 24;
    # }];
    #    networking.interfaces."${porty_usb_if}".ipv4.addresses = [{
    #      address = "10.88.0.1";
    #      prefixLength = 24;
    #    }];
    #    networking.nat = {
    #      enable = true;
    #      internalInterfaces = [
    #        # "enp9s0f3u2u3u1"
    #        "${porty_usb_if}"
    #      ];
    #      externalInterface = "eth0";
    #      internalIPs = [ "10.0.0.0/16" ];
    #    };

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      cpu.amd.updateMicrocode = true;
    };
    boot.loader.grub.pcmemtest.enable = true;
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [
      "hv_vmbus"
      "hv_storvsc" # for booting under hyperv
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "ehci_pci"
      "uas"
    ];

    fileSystems."/" = { fsType = "zfs"; device = "portypool/root"; };
    fileSystems."/nix" = { fsType = "zfs"; device = "portypool/nix"; };
    fileSystems."/home" = { fsType = "zfs"; device = "portypool/home"; };
    fileSystems."/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/porty-boot"; };

    boot.initrd.luks.devices."porty-luks" = {
      allowDiscards = true;
      device = "/dev/disk/by-partlabel/porty-luks";

      keyFile = "/lukskey";
      fallbackToPassword = true;
    };
    boot.initrd.secrets = {
      "/lukskey" = pkgs.writeText "lukskey" "test";
    };

    swapDevices = [ ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?

    services.fwupd.enable = true;
  };
}
