{ pkgs, lib, modulesPath, inputs, config, ... }:

## RPI-TOW-BOOT INTEGRATION

{
  imports = inputs.tow-boot.nixosModules;

  config = {
    tow-boot.enable = true;
    tow-boot.autoUpdate = true;
    tow-boot.device = "raspberryPi-aarch64";
    # configuration.config.Tow-Boot = {
    tow-boot.config = ({
      diskImage.mbr.diskID = config.system.build.mbr_disk_id;
      uBootVersion = "2022.04";
      useDefaultPatches = false;
      withLogo = false;
      rpi = {
        mainlineKernel = inputs.rpipkgs.legacyPackages.${pkgs.system}.linuxPackages_latest.kernel;
        foundationKernel = inputs.rpipkgs.legacyPackages.${pkgs.system}.linuxPackages_rpi4.kernel;
        #firmwarePackage = inputs.rpipkgs.legacyPackages.${pkgs.system}.raspberrypifw;
        firmwarePackage = inputs.rpipkgs.legacyPackages.${pkgs.system}.raspberrypifw-master;
      };
    });
  };
}
