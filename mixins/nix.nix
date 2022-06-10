{ config, lib, pkgs, inputs, ... }:

with lib;

let
  _nixUnstableXdg = pkgs.nixUnstable.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "Artturin";
      repo = "nix";
      rev = "0c4a30eecc22a7e10cddba4612df484ade3e291f";
      sha256 = "sha256-HNU+jltYw3gdt9ApI21zUoojy0aJ4y1x7kidkWZkKg0=";
    };
  });
  # _nix = _nixUnstableXdg;
  _nix = pkgs.nixUnstable.overrideAttrs(old: {
    patches = (old.patches or []) ++ [
      ../misc/0001-flakes-flake.lock-location-env-var.patch
    ];
  });
in
{
  config = {
    environment.systemPackages = [ _nix ];
    nix = {
      settings = {
      keep-derivations = true; # this is the default (?)
        cores = 0;
        max-jobs = "auto";
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://colemickens.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
          "https://unmatched.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-users = [ "@wheel" "root" ];
      };
      package = _nix;
      extraOptions =
        #lib.optionalString (config.nix.package == pkgs.nixUnstable)
        #"experimental-features = nix-command flakes ca-references recursive-nix";
        "experimental-features = nix-command flakes recursive-nix";
    };
  };
}

