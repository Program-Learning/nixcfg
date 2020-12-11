{ config, pkgs, inputs, ... }:

let
  desktops = [
    #"elementary"
    #"gnome"
    #"plasma"
    "sway-unstable"
    "sway"
  ];
in
{
  config = {
    specialisation = 
      pkgs.lib.genAttrs desktops (desktop:
        {
          configuration = { 
            boot.loader.grub.configurationName = "sway";
            imports = [ ./desktop-sway.nix ];
          };
        }
      );
  };
}