{ pkgs, config }:

rec {
  rcloneConfigFile = config.sops.secrets."rclone.conf".path;

  sops.secrets."rclone.conf" = {
    owner = "cole";
    group = "cole";
  };

  rclone-lim = pkgs.writeScriptBin "rclone-lim" ''
    #!/usr/bin/env bash
    ${pkgs.rclone}/bin/rclone --config "${rcloneConfigFile}" "''${@}"
  '';

  rclone-lim-mount = readonly: (pkgs.writeScriptBin "rclone-lim-mount" ''
    #!/usr/bin/env bash
    ${pkgs.rclone}/bin/rclone \
      --config ${rcloneConfigFile} \
      --fast-list \
      --drive-skip-gdocs \
      --vfs-read-chunk-size=64M \
      --vfs-read-chunk-size-limit=2048M \
      --vfs-cache-mode writes \
      --buffer-size=128M \
      --max-read-ahead=256M \
      --poll-interval=1m \
      --dir-cache-time=168h \
      --timeout=10m \
      --transfers=16 \
      --checkers=12 \
      --drive-chunk-size=64M \
      --fuse-flag=sync_read \
      --fuse-flag=auto_cache \
      ${if readonly then "--read-only \\" else "\\"}
      --umask=002 \
      -v \
      mount ''${@}
  '');

  rclone-lim-mount-all = (pkgs.writeScriptBin "rclone-lim-mount-all" ''
    #!/usr/bin/env bash
    set -x
    pids=()
    mnts=( "tvshows" "movies" "misc" "backups" "archives" )
    for m in "''${mnts[@]}"; do
      sudo fusermount -uz "''${HOME}/mnt/''$m"
    done
    for m in "''${mnts[@]}"; do
      mkdir -p "''${HOME}/mnt/''$m"
      sudo fusermount -u "''${HOME}/mnt/''$m"
      "${rclone-lim-mount}/bin/rclone-lim-mount" "''$m:" "''${HOME}/mnt/''$m" &
      trap "set +x; kill ''$!; sudo fusermount -uz ''${HOME}/mnt/''$m || true; rm -f ''${HOME}/mnt/''$m" EXIT
    done
    wait
  '');
}
