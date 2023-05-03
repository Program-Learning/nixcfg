{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "vf2";
  pp = "vf2";
in
{
  imports = [
    ../../profiles/core.nix
    inputs.nixos-hardware.outputs.nixosModules.starfive-visionfive-2
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";
    system.stateVersion = "22.11";

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    networking.hostName = hn;
    hardware.deviceTree.name = "starfive/jh7110-starfive-visionfive-2-v1.2a.dtb";

    nix.nixPath = [ ];
    # nix.gc.automatic = true;

    nixcfg.common.defaultKernel = false;
    nixcfg.common.addLegacyboot = false;
    nixcfg.common.useZfs = false;

    # environment.systemPackages = with pkgs; [
    #   binutils
    #   usbutils
    # ];

    boot = {
      # see: https://github.com/starfive-tech/linux/issues/101#issuecomment-1550787967
      blacklistedKernelModules = [ "clk-starfive-jh7110-vout" ];
      enableContainers = false;
      bootspec.enable = true;
      # lanzaboote = {
      #   enable = true;
      #   pkiBundle = "/etc/secureboot";
      #   configurationLimit = 4;
      # };
      loader = {
        efi.efiSysMountPoint = "/efi";
        grub.enable = false;
        # systemd-boot.enable = true;
        systemd-boot.enable = false;
        generic-extlinux-compatible.enable = lib.mkForce true;
        generic-extlinux-compatible.configurationLimit = 3;
      };

      tmp.useTmpfs = lib.mkForce false;
      # tmp.cleanOnBoot = false;

      # copied from: (https://github.com/NickCao/nixos-riscv/blob/55ec013f21dcf3da60f42b2d0c4f91c6183da2d8/visionfive2.nix#LL19C5-L19C79)
      # TODO: needed? upstream to nixos-hardware?
      initrd.kernelModules = [
        "motorcomm"
        "nvme" "nvme_core"
        "pcie_starfive"
        "phy_jh7110_pcie"
        "xhci_pci" "xhci_pci_renesas" "xhci_hcd"
        "dwmac-starfive"

        # pcie clocks for NVME (likely not all needed)
        "clk-starfive-jh71x0"
        "clk-starfive-jh7110-aon"
        "clk-starfive-jh7110-stg"
        "clk-starfive-jh7110-sys"
      ];
    };
  };
}
