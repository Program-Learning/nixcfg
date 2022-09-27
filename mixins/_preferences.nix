{ pkgs, inputs, ... }:

let
  # colorscheme = inputs.nix-rice.colorschemes."purplepeter";
  colorscheme = inputs.nix-rice.colorschemes."Gruvbox Dark";
  # colorscheme = inputs.nix-rice.colorschemes."Ocean";

  bg_gruvbox_rainbow = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/0797f8f90a440fbc1c0a412c133e4814034b0b50/png/gruvbox-dark-rainbow-square.png";
    sha256 = "1qggwqx0flqxk0ckv4x0a1gbhpchbaqvlpm8xc7xys1kbgwh4d45";
  };
  colordefs = {
    bold_as_bright = true;
  };
  customIosevkaTerm = (pkgs.iosevka.override {
    set = "term";
    # https://github.com/be5invis/Iosevka/blob/6b2b8b7e643a13e1cf56787aed4fd269dd3e044b/build-plans.toml#L186
    privateBuildPlan = {
      family = "Iosevka Term";
      spacing = "term";
      snapshotFamily = "iosevka";
      snapshotFeature = "\"NWID\" on, \"ss03\" on";
      export-glyph-names = true;
      no-cv-ss = true;
    };
  });
  # _iosevka = pkgs.iosevka; # weird aarch64 build failure?
  # _iosevka = pkgs.iosevka-bin;
  _iosevka = pkgs.iosevka-comfy.comfy-fixed;
  #_iosevka = customIosevkaTerm;
  
  # TODO: fix
  # cursorColor = "#EA0A8E";
  # custom-bibata-cursors = pkgs.bibata-cursors.overrideAttrs(old: {
  #   postPatch = (old.postPatch or "") + ''
  #     substituteInPlace "./bitmapper/src/config.ts" \
  #       --replace "#FF8300" "${cursorColor}"
  #   '';
  # });
in
rec {
  # all configured with HM, so just use binary name
  editor = "hx";
  shell = { program = "zsh"; args = [ ]; };
  default_term = "alacritty";
  default_launcher = "sirula";

  gtk = {
    font = { name = "${font.default.family} 11"; package = font.default.package; };
    preferDark = true;

    # iconTheme = { name = "Numix Circle"; package = pkgs.numix-icon-theme; };
    iconTheme = { name = "Tela-circle-dark"; package = pkgs.tela-circle-icon-theme; };
# T # iconTheme = { name = "Fluent"; package = pkgs.fluent-icon-theme; };
# T # iconTheme = { name = "Colloid"; package = pkgs.colloid-icon-theme; };
    # iconTheme = { name = "WhiteSur-dark"; package = pkgs.whitesur-icon-theme; };
# T # iconTheme = { name = "McMojave-circle"; package = pkgs.mcmojave-icon-theme; };

    theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
    # theme = { name = "Orchis-purple-dark-compact"; package = pkgs.orchis-theme; };
    # theme = { name = "WhiteSur-dark-solid"; package = pkgs.whitesur-gtk-theme; };
    # theme = { name = "Mojave-dark-solid"; package = pkgs.mojave-gtk-theme; };
#ew # theme = { name = "Marwaita Color Dark"; package = pkgs.marwaita; };
    # theme = { name = "Qogir-dark"; package = pkgs.qogir-theme; };
  };
  
  ## cursor
  # cursor = { name = "capitaine-cursors-white"; package = pkgs.capitaine-cursors; };
#T# cursor = { name = "apple-cursor"; package = pkgs.apple-cursor; };
  # cursor = { name = "Bibata-Original-Amber"; package = pkgs.bibata-cursors; };
  # cursor = null;
  # cursor = { name = "Bibata-Original-Amber"; package = custom-bibata-cursors; };
#T#cursor = { name = "Graphite"; package = pkgs.graphite-cursors; };
#T# cursor = { name = "Qogir"; package = pkgs.qogir-cursors; }; # not packaged
  # cursor = { name = "phinger-cursors-light"; package = pkgs.phinger-cursors; };
  cursor = { name = "macOSBigSur"; package = pkgs.apple-cursor; };
  cursorSize = 48;
  
  themes = {
    alacritty = colorscheme // colordefs;
    sway = colorscheme // colordefs;
    wezterm = colorscheme // colordefs;
    zellij = colorscheme // colordefs;
  };
  inherit colorscheme;

  bgcolor = "#000000";
  # background = "${bgcolor} solid_color";
  background = "${bg_gruvbox_rainbow} fit #282828";
  wallpaper = bg_gruvbox_rainbow;

  swayfonts = {
    names = [ font.default.family font.fallback.family ];
    style = "Heavy";
    size = 10.0;
  };

  font = rec {
    size = 13;
    default = sans;

    sans = { family = "Noto Sans"; package = pkgs.noto-fonts; };
    serif = { family = "Noto Serif"; package = pkgs.noto-fonts; };
    monospace = { family = "Iosevka Comfy Fixed"; package = _iosevka; };
    fallback = { family = "Font Awesome 5 Free"; package = pkgs.font-awesome; };
    emoji = { family = "Noto Color Emoji"; package = pkgs.noto-fonts-emoji; };
    
    allPackages = (map (p: p.package)
      [
        default
        sans
        serif
        monospace
        fallback
        emoji
      ]) ++
      (with pkgs; [
        liberation_ttf # free corefonts-metric-compatible replacement
        ttf_bitstream_vera
        gelasio
        powerline-symbols
      ]);
  };
}
