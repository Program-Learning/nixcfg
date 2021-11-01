{ pkgs, ... }:

{
  config = {
    # put this in a "pipewire.nix" ??
    services.pipewire.enable = true;

    # split out into profile-gnome and profile-sway
    # xdg.portal.enable = true;
    # xdg.portal.gtkUsePortal = true;
    # xdg.portal.extraPortals = with pkgs;
    #   [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    home-manager.users.cole = { pkgs, ... }: {
      xdg.userDirs = {
        enable = true;
        desktop = "\$HOME/desktop";
        documents = "\$HOME/documents";
        download = "\$HOME/downloads";
        music = "\$HOME/documents/music";
        pictures = "\$HOME/documents/pictures";
        publicShare = "\$HOME/documents/public";
        templates = "\$HOME/documents/templates";
        videos = "\$HOME/documents/videos";
      };
    };
  };
}
