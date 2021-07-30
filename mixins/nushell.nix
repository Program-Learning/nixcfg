{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {  
      programs.nushell = {
        enable = (pkgs.system == "x86_64-linux" || pkgs.system == "aarch64-linux");

        settings = pkgs.lib.mkMerge [
          {
            edit_mode = "vi";
            startup = [ "alias ll [] { ls -l }" ];
            completion_mode = "circular";
            key_timeout = 10;
          }

          {
            startup = [ "alias e [msg] { echo $msg }" ];
            no_auto_pivot = true;
          }
        ];
      };
    };
  };
}
