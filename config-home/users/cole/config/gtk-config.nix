{ pkgs, ... }:

{
  enable = true;
  #preferDark = true;
  font = { name = "Noto Sans 11"; package = pkgs.noto-fonts; };
  iconTheme = { name = "Numix"; package = pkgs.numix-icon-theme; };
  #cursorTheme = { name = "capitaine-cursors-white"; package = pkgs.capitaine-cursors; };
  theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
  gtk3.extraConfig = {
    #gtk-cursor-theme-size = 0;
    gtk-xft-antialias = 1;
    gtk-xft-hinting = 1;
    gtk-xft-hintstyle = "hintfull";
  };
}
