{ pkgs, ... }:

{
  enable = true;

  historyLimit = 100000;
  escapeTime = 0;
  keyMode = "vi";
  #mouseBindings = true; # TODO
  newSession = true;
  sensibleOnTop = true;
  extraConfig = ''
    set -g mouse on
  '';
}

