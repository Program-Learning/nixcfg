{ config, pkgs, inputs, ... }:

let
  swayfont = "Iosevka Bold 9";
  barfont = "Iosevka Bold 9"; # font matches waybar-config.css
  editor = "${pkgs.vscodium}/bin/codium";

  wofi = "${pkgs.wofi}/bin/wofi --insensitive";
  drun = "${wofi} --show drun";
  nwggrid = "${pkgs.nwg-launchers}/bin/nwggrid";

  #terminal = "${pkgs.termite}/bin/termite";
  terminal = "${pkgs.alacritty}/bin/alacritty";
  #terminal = "${pkgs.kitty}/bin/kitty";
  #browser = "${pkgs.firefox-bin}/bin/firefox";
  #browser = "${inputs.firefox.firefox-nightly-bin}/bin/firefox";
  browser = "firefox-nightly";

  # PASS
  gp = "${pkgs.gopass}/bin/gopass";
  smsg = "${pkgs.sway}/bin/swaymsg";
  passShowCmd = "${gp} ls --flat | ${wofi} --dmenu | xargs -r ${smsg} -t command exec -- ${gp} show --clip";
  passTotpCmd = "${gp} ls --flat | ${wofi} --dmenu | xargs -r ${smsg} -t command exec -- ${gp} totp --clip";

  # OUTPUTS
  out_laptop = "Sharp Corporation 0x148B 0x00000000";
  out_alien = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";

  # INPUTS
  in_pine_touchpad = "9610:30:HAILUCK_CO.,LTD_USB_KEYBOARD_Touchpad";
  in_touchpad = "1739:30383:DELL07E6:00_06CB:76AF_Touchpad";
  in_logi = "1133:16505:Logitech_G_Pro";

  i3statusConfig = import ./i3status-rust-config.nix { inherit pkgs; };
  i3statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${i3statusConfig}";
  waybarCommand = "${pkgs.waybar}/bin/waybar";
  statusCommand = waybarCommand; # switch back?

  # idle/lock
  # TODO: test and fix/ remove this message
  swaylockcmd = "${pkgs.swaylock}/bin/swaylock -f -c '#000000'";
  idlecmd = ''${pkgs.swayidle}/bin/swayidle -w \
    before-sleep \"${swaylockcmd}\" \
    lock \"${swaylockcmd}\" \
    timeout 500 \"${swaylockcmd}\" \
    timeout 1000 \"${pkgs.systemd}/bin/systemctl suspend\"'';

  # silly gtk/gnome wayland schenanigans
  # TODO: see if this is necessary if we get HM to do it? or our own systemd user units?
  gsettings="${pkgs.glib}/bin/gsettings";
  gsettingsscript = pkgs.writeShellScript "gsettings-auto.sh" ''
    expression=""
    for pair in "$@"; do
      IFS=:; set -- $pair
      expressions="$expressions -e 's:^$2=(.*)$:${gsettings} set org.gnome.desktop.interface $1 \1:e'"
    done
    IFS=
    echo "" >/tmp/gsettings.log
    echo exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini &>>/tmp/gsettings.log
    eval exec sed -E $expressions "''${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini &>>/tmp/gsettings.log
  '';
  gsettingscmd = ''${gsettingsscript} \
    gtk-theme:gtk-theme-name \
    icon-theme:gtk-icon-theme-name \
    font-name:gtk-font-name \
    cursor-theme:gtk-cursor-theme-name'';

  # change output scales incrementally w/ kb shortcuts
  outputScale = pkgs.writeShellScript "scale-wlr-outputs.sh" ''
    set -xeuo pipefail
    delta=''${1}

    scale="$(swaymsg -t get_outputs | ${pkgs.jq}/bin/jq '.[] | select(.focused == true) | .scale')"
    printf -v scale "%.1f" "''${scale}"
    scale="$(echo "''${scale} ''${delta}" | ${pkgs.bc}/bin/bc)"

    swaymsg output "-" scale "''${scale}"
  '';
in
{
  config = {
    programs.sway.enable = true; # needed for swaylock/pam stuff
    programs.sway.extraPackages = []; # block rxvt

    environment.systemPackages = with pkgs; [
      capitaine-cursors
    ];

    home-manager.users.cole = { pkgs, ... }: {
      wayland.windowManager.sway = {
        enable = true;
        #systemdIntegration = true; # beta
        wrapperFeatures = {
          base = true; # this is the default, but be explicit for now
          gtk = true;
        };
        # extraSessionCommands = ''
        #   export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        #   systemctl --user import-environment
        # '';
        xwayland = true;
        extraConfig = ''
          seat seat0 xcursor_theme "capitaine-cursors"
        '';
        config = rec {
          modifier = "Mod4";
          inherit terminal;
          fonts = [ swayfont ];
          focus.followMouse = "always";
          window.border = 4;
          window.titlebar = true;
          window.commands = [
            { criteria = { app_id = "mpv"; }; command = "sticky enable"; }
            { criteria = { app_id = "mpv"; }; command = "floating enable"; }

            {
              criteria = { title = "^(.*) Indicator"; };
              command = "floating enable";
            }

            {
              criteria = { instance = "pinentry"; };
              command = "fullscreen on";
            }
          ];
          startup = [
            { always = true; command = "${gsettingscmd}"; }
            { always = true; command = "${pkgs.xorg.xrdb}/bin/xrdb -l $HOME/.Xresources"; }
            { always = true; command = "${pkgs.systemd}/bin/systemd-notify --ready || true"; }
            { always = true; command = "${pkgs.mako}/bin/mako"; }

            { always = true;  command = "pkill swayidle"; } # Disable swayidle for a bit
            #{ command = "${idlecmd}"; always = true; }     # Disable swayidle for a bit
          ];
          input = {
            "${in_touchpad}" = {
              click_method = "clickfinger";
              tap = "enabled";
              dwt = "enabled";
              scroll_method = "two_finger";
              natural_scroll = "enabled";
              accel_profile = "adaptive";
              pointer_accel = "1";
            };
            "${in_pine_touchpad}" = {
              click_method = "clickfinger";
              tap = "enabled";
              dwt = "enabled";
              scroll_method = "two_finger";
              natural_scroll = "enabled";
              accel_profile = "adaptive";
              pointer_accel = ".5";
            };
            "${in_logi}" = {
              accel_profile = "adaptive";
              pointer_accel = ".1";
            };
          };
          output = {
            #"${out_laptop}" = {
            #  mode = "3480x2160@59.997002Hz";
            #  subpixel = "rgb";
            #  scale = "2.0";
            #};
            "${out_laptop}" = { disable = ""; }; # disable laptop display for a bit
            "${out_alien}" = {
              #mode = "3440x1440@120Hz";
              #mode = "3440x1440Hz";
              # don't force alienware to be a certain refresh rate (it depends what adapter is used :/)
              subpixel = "rgb";
              scale = "1.0";
              adaptive_sync = "on";
            };
            "*" = {
              background = "#185373 solid_color";
            };
          };
          bars = [{
            #fonts = [ barfont ];
            #position = "top";
            command = statusCommand;
            #inherit statusCommand;
          }];
          keybindings = {
            "${modifier}+Return" = "exec ${terminal}";
            #"${modifier}+Shift+Return" = "exec ${browser}";
            #"${modifier}+Shift+Backspace" = "exec ${editor}";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Delete" = "${swaylockcmd}";

            "${modifier}+Escape" = "exec ${nwggrid}";
            "${modifier}+F1" = "exec ${passShowCmd}";
            "${modifier}+F2" = "exec ${passTotpCmd}";

            "${modifier}+Ctrl+Alt+Delete" = "exit";

            "Ctrl+q" = "exec echo"; # the most ridiculous firefox bug ever

            "${modifier}+Left" = "focus left";
            "${modifier}+Down" = "focus down";
            "${modifier}+Up" = "focus up";
            "${modifier}+Right" = "focus right";

            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Right" = "move right";

            "${modifier}+Prior" = "workspace prev";
            "${modifier}+Next" = "workspace next";

            "${modifier}+b" = "splith";
            "${modifier}+v" = "splitv";
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+a" = "focus parent";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+Shift+Alt+space" = "sticky toggle";
            "${modifier}+space" = "focus mode_toggle";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 10";

            "${modifier}+Shift+minus" = "move scratchpad";
            "${modifier}+minus"       = "scratchpad show";

            "${modifier}+Ctrl+Alt+Home"  = "output * enable";
            "${modifier}+Ctrl+Alt+End"   = "output -- disable";
            "${modifier}+Ctrl+Alt+equal" = "exec ${outputScale} +.1";
            "${modifier}+Ctrl+Alt+minus" = "exec ${outputScale} -.1";

            "${modifier}+Print"       = ''exec ${pkgs.grim}/bin/grim \"''${HOME}/screenshot-$(date '+%s').png\"'';
            "${modifier}+Shift+Print" = ''exec ${pkgs.grim}/bin/grim  -g \"$(slurp)\" \"''${HOME}/screenshot-$(date '+%s').png\"'';

            "${modifier}+Ctrl+Alt+Up"    = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10";
            "${modifier}+Ctrl+Alt+Down"  = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10-";
            "${modifier}+Ctrl+Alt+Prior" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +100";
            "${modifier}+Ctrl+Alt+Next"  = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 100-";
            "${modifier}+Ctrl+Alt+Left"  = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume -2";
            "${modifier}+Ctrl+Alt+Right" = "exec ${pkgs.pulsemixer}/bin/pulsemixer --change-volume +2";
          };
        };
      };
    };
  };
}
