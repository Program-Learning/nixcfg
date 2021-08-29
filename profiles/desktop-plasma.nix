{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {

      };
      home.packages = with pkgs; [
        pavucontrol-qt
        
        #kedit
        konsole
      ];
    };
  };
}
