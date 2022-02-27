args_@{ lib
, fetchFromGitHub
, bottom
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules, pkg-config
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/ClementTsang/bottom";
    branch = "master";
    rev = "adf1e2b2164eec90950f2c11428796a62628f2e9";
    sha256 = "sha256-t7T5EOestM9MxSkNN9WXR6NsCW/17ApuJg2Vk+I6KD4=";
    cargoSha256 = "sha256-t7T5EOestM9MxSkNN9WXR6NsCW/17ApuJg2Vk+I6KD4=";
    version = rev;
  };
  extraNativeBuildInputs = [
    # "extra-cmake-modules" "pkg-config"
  ];
  extraBuildInputs = [
    # "qqc2-desktop-style" "sonnet" "kio"
  ];
  ignore = [ "bottom" "fetchFromGithub" "runCommandNoCC" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
  newsrc = bottom.src.overrideAttrs(old: {
    inherit (metadata) rev sha256;
  });
  cargo_new_version = builtins.substring 0 10 metadata.rev;
in
(bottom.override args).overrideAttrs(old: rec {
  pname = "bottom";
  version = cargo_new_version;
  src = newsrc;

  cargoDeps = old.cargoDeps.overrideAttrs (lib.const {
    src = newsrc;
    name = "${pname}-${cargo_new_version}-vendor.tar.gz";
    outputHash = metadata.cargoSha256;
  });

  buildInputs = old.buildInputs ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = old.nativeBuildInputs ++ (map (n: args_.${n}) extraNativeBuildInputs);

  meta = (old.meta or {}) // { description = "${old.description or pname}"; verinfo = metadata; };
})
