#!/usr/bin/env bash
set -euo pipefail
set -x

cachixremote="colemickens"

function update() {
  attr="${1}"
  owner="${2}"
  repo="${3}"
  ref="${4}"

  rev=""
  url="https://api.github.com/repos/${owner}/${repo}/commits?sha=${ref}"
  rev="$(git ls-remote "https://github.com/${owner}/${repo}" "${ref}" | cut -d '	' -f1)"
  [[ -f "./${attr}/metadata.nix" ]] && oldrev="$(nix eval -f "./${attr}/metadata.nix" rev --raw)"
  if [[ "${oldrev:-}" != "${rev}" ]]; then
    revShort="$(git rev-parse --short "${rev}")"
    revdata="$(curl -L --fail "https://api.github.com/repos/${owner}/${repo}/commits/${rev}")"
    revdate="$(echo "${revdata}" | jq -r ".commit.committer.date")"
    sha256="$(nix-prefetch-url --unpack "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz" 2>/dev/null)"
    printf '{\n  owner = "%s";\n  repo = "%s";\n  rev = "%s";\n  revShort = "%s";\n  sha256 = "%s";\n  revdate = "%s";\n}\n' \
      "${owner}" "${repo}" "${rev}" "${revShort}" "${sha256}" "${revdate}" > "./${attr}/metadata.nix"
  fi
}
update "imports/nixpkgs/nixos-unstable"       "nixos"       "nixpkgs-channels" "nixos-unstable"
update "imports/nixpkgs/cmpkgs"               "colemickens" "nixpkgs"          "cmpkgs"
update "imports/nixos-hardware"               "nixos"       "nixos-hardware"   "master"
update "imports/nixpkgs-mozilla"              "mozilla"     "nixpkgs-mozilla" "master"
update "imports/nixpkgs-wayland"              "colemickens" "nixpkgs-wayland"  "master"

update "pkgs/gopass"  "gopasspw" "gopass" "master"

set +o pipefail
set +e

unset NIX_PATH
./nixbuild.sh default.nix -A "xeep_sway__local.config.system.build.toplevel" | cachix push "${cachixremote}"
./nixbuild.sh default.nix -A "xeep_plasma__local.config.system.build.toplevel" | cachix push "${cachixremote}"
./nixbuild.sh default.nix -A "xeep_gnomeshell__local.config.system.build.toplevel" | cachix push "${cachixremote}"

set -euo pipefail
./nixbuild.sh default.nix -A "xeep_sway__local.config.system.build.toplevel" | cachix push "${cachixremote}"

