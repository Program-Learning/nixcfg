{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  pp = "vf2";
in
{
  imports = [
    ./inner.nix
    ./fs.nix
    ../../profiles/addon-cross.nix
    ../../profiles/interactive.nix
    ../../mixins/gfx-visionfive2.nix
    ../../profiles/gui-sway-auto.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      picocom
      rkdeveloptool
      rkflashtool
    ];
  };
}
