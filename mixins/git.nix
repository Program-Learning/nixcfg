{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      sops.secrets = {
        "github-signingkey-detsys" = {
          format = "binary";
          sopsFile = ../secrets/encrypted/github-signingkey-detsys;
        };
      };

      programs.git = {
        enable = true;
        signing.key = "8329C1934DA5D818AE35F174B475C2955744A019";
        signing.signByDefault = true;
        userEmail = "cole.mickens@gmail.com";
        userName = "Cole Mickens";

        extraConfig = {
          core = {
            untrackedCache = true;
            fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
          };
          safe = {
            directory = "/home/cole/code/nixcfg";
          };
        };

        ignores = [ ".direnv" ];

        includes = [
          {
            condition = "gitdir:~/work/";
            contents = {
              user = {
                name = "Cole Mickens";
                email = "cole.mickens@determinate.systems";
                signingkey = "/run/user/1000/secrets/github-signingkey-detsys";
              };
              gpg = {
                format = "ssh";
              };
            };
          }
        ];
        # delta = {
        #   enable = true;
        #   options = {
        #     features = "decorations side-by-side navigate";
        #   };
        # };

        difftastic = {
          enable = true;
        };
      };
    };
  };
}
