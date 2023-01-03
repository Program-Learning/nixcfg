{ pkgs, lib, config, inputs, ... }:

let
  _xwayland = rec {
    enable = true;
    hidpi = enable;
  };
in
{
  imports = [
    ./gui-wayland.nix

    inputs.hyprland.nixosModules.default
  ];
  config = {
    environment.sessionVariables = {
      WLR_RENDERER = "vulkan";
    };
    programs.hyprland = {
      enable = true;
      xwayland = _xwayland;
    };
    programs.xwayland.enable = _xwayland.enable; # TODO: hyprland should follow itself

    home-manager.users.cole = { pkgs, ... }: {
      imports = [
        inputs.hyprland.homeManagerModules.default
      ];
      home.packages = with pkgs; [
        wlr-randr
        glpaper
      ];
      wayland.windowManager.hyprland = {
        enable = true;
        systemdIntegration = true;
        recommendedEnvironment = true;
        xwayland = _xwayland;
        extraConfig = ''
          # This is an example Hyprland config file.
          #
          # Refer to the wiki for more information.

          #
          # Please note not all available settings / options are set here.
          # For a full list, see the wiki
          #

          # See https://wiki.hyprland.org/Configuring/Monitors/
          monitor=,preferred,auto,auto
          monitor=desc:Dell Inc. Dell AW3418DW ##ASPD8psOnhPd,3440x1440@120,auto,1

          # See https://wiki.hyprland.org/Configuring/Keywords/ for more

          # Execute your favorite apps at launch
          # exec-once = waybar & hyprpaper & firefox

          # Source a file (multi-file configs)
          # source = ~/.config/hypr/myColors.conf

          # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
          input {
              kb_layout = us
              kb_variant =
              kb_model =
              kb_options =
              kb_rules =

              follow_mouse = 1

            touchpad {
              disable_while_typing=1
              natural_scroll=1
              clickfinger_behavior=1
              middle_button_emulation=0
              tap-to-click=0
            }

              sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
          }

          general {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              gaps_in = 3
              gaps_out = 20
              border_size = 5
              col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
              # col.active_border = rgba(05d6d9ff) rgba(f907fcff) 45deg
              # col.active_border = rgba(ff0d0dff)
              # col.active_border = rgba(ffffffff)
              col.inactive_border = rgba(59595900)

              layout = dwindle
          }

          decoration {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              rounding = 5
              blur = no
              blur_size = 8
              blur_passes = 2
              blur_new_optimizations = on

              drop_shadow = yes
              shadow_range = 4
              shadow_render_power = 3
              col.shadow = rgba(1a1a1aee)

              # dim_inactive = true
              # dim_strength = 0.20
          }

          animations {
              # enabled = yes
              enabled = no
              
              # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

              bezier = myBezier, 0.05, 0.9, 0.1, 1.05

              animation = windows, 1, 7, myBezier
              animation = windowsOut, 1, 7, default, popin 80%
              animation = border, 1, 10, default
              animation = fade, 1, 7, default
              animation = workspaces, 1, 6, default
          }

          dwindle {
              # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
              pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
              preserve_split = yes # you probably want this
          }

          master {
              # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
              new_is_master = true
          }

          gestures {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more
              workspace_swipe = on
          }

          misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
            no_vfr = false
          }

          # Example per-device config
          # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
          device:epic mouse V1 {
              sensitivity = -0.5
          }

          # Example windowrule v1
          # windowrule = float, ^(kitty)$
          # Example windowrule v2
          # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
          # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
          # windowrulev2 = opacity 0.85 0.85,class:^(Alacritty)$
          # windowrulev2 = opacity 0.85 0.85,class:^(org.wezfurlong.wezterm)$


          # See https://wiki.hyprland.org/Configuring/Keywords/ for more
          $mainMod = SUPER

          # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
          bind = SUPER,return,exec,alacritty
          bind = SUPER,escape,exec,sirula
          bind = SUPERSHIFT,space,togglefloating, 
          bind = SUPERSHIFTALT,space,pin, # ...
          bind = SUPER,P,pseudo, # dwindle
          bind = SUPER,F,fullscreen,1 # ...
          bind = SUPERSHIFT,F,fullscreen,0 # ...
          bind = SUPER,T,togglesplit, # dwindle
          bind = SUPERSHIFT,Q,killactive, # ...
          bind = ALTCTRLSUPER, delete, exit, # ...

          # Move focus with mainMod + arrow keys
          bind = $mainMod, H, movefocus, l
          bind = $mainMod, L, movefocus, r
          bind = $mainMod, K, movefocus, u
          bind = $mainMod, J, movefocus, d

          # Switch workspaces with mainMod + [0-9]
          bind = $mainMod, 1, workspace, 1
          bind = $mainMod, 2, workspace, 2
          bind = $mainMod, 3, workspace, 3
          bind = $mainMod, 4, workspace, 4
          bind = $mainMod, 5, workspace, 5
          bind = $mainMod, 6, workspace, 6
          bind = $mainMod, 7, workspace, 7
          bind = $mainMod, 8, workspace, 8
          bind = $mainMod, 9, workspace, 9
          bind = $mainMod, 0, workspace, 10

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          bind = $mainMod SHIFT, 1, movetoworkspace, 1
          bind = $mainMod SHIFT, 2, movetoworkspace, 2
          bind = $mainMod SHIFT, 3, movetoworkspace, 3
          bind = $mainMod SHIFT, 4, movetoworkspace, 4
          bind = $mainMod SHIFT, 5, movetoworkspace, 5
          bind = $mainMod SHIFT, 6, movetoworkspace, 6
          bind = $mainMod SHIFT, 7, movetoworkspace, 7
          bind = $mainMod SHIFT, 8, movetoworkspace, 8
          bind = $mainMod SHIFT, 9, movetoworkspace, 9
          bind = $mainMod SHIFT, 0, movetoworkspace, 10

          # Scroll through existing workspaces with mainMod + scroll
          bind = $mainMod, mouse_down, workspace, e+1
          bind = $mainMod, mouse_up, workspace, e-1

          # Move/resize windows with mainMod + LMB/RMB and dragging
          bindm = $mainMod, mouse:272, movewindow
          bindm = $mainMod, mouse:273, resizewindow
        '';
      };
    };
  };
}
