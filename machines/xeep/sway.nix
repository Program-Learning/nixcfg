{ pkgs, ... }:

{
  imports = [
    ./base.nix
    ../../modules/profile-sway.nix
    ../../modules/mixin-intel-iris.nix
  ];
}
