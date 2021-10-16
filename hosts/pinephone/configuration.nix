{ pkgs, config, inputs, ... }:

let
  hostname = "pinephone";
in
{
  imports = [
    ../../profiles/user.nix
    ../../profiles/interactive.nix
    ../../profiles/desktop-sway-unstable.nix
    
    ../../modules/loginctl-linger.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "pine64-pinephone";
    })
  ];

  config = {
      #
      # TODO: investigate:
      #
      # https://github.com/Dejvino/pinephone-sway-poc
      # package: https://git.sr.ht/~mil/lisgd
      # https://aur.archlinux.org/packages/squeekboard/
      # https://github.com/efernau/rot8

      environment.systemPackages = with pkgs; [
        pipes
      ];

      users.users.cole.linger = true;

      networking.hostName = hostname;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ inputs.self.overlay ];

      ### BEGIN HACKY COPY
  };
}
