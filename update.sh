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
    printf '{\n  rev = "%s";\n  revShort = "%s";\n  sha256 = "%s";\n  revdate = "%s";\n}\n' \
      "${rev}" "${revShort}" "${sha256}" "${revdate}" > "./${attr}/metadata.nix"
  fi
}

# nixpkgs
update "imports/nixpkgs/nixos-unstable" "nixos" "nixpkgs-channels" "nixos-unstable"

# module-ish imports
update "imports/nixos-hardware"   "nixos"      "nixos-hardware"  "master"

# my own packages not in nixpkgs-wayland or nixpkgs upstream
update "pkgs/gopass"           "gopasspw"   "gopass"          "master"
update "pkgs/gitstatus"        "romkatv"    "gitstatus"       "master"
update "pkgs/libgit2"          "romkatv"    "libgit2"         "master"

unset NIX_PATH
nix-build \
  --option build-cores 0 \
  --no-out-link \
  configurations/xeep.nix

nix-build --no-out-link --keep-going default.nix

# push all to cachix
nix-build --no-out-link --keep-going default.nix \
  | cachix push "${cachixremote}"

