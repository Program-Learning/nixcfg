{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, runCommand
, rustPlatform
, openssl
, zlib
, zstd
, pkg-config
, python3
, xorg
, libiconv
, Libsystem
, AppKit
, Security
, nghttp2
, libgit2
, doCheck ? true
, withDefaultFeatures ? true
, additionalFeatures ? (p: p)
, testers
, nushell
, nix-update-script
}:

rustPlatform.buildRustPackage (
  let
    version = "unstable-2023-11-02";
    rev = "0ca8fcf58c02bef31f1eb65e001d71f5648b3b35";
    owner = "nushell";
    pname = "nushell";
    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = rev;
      sha256 = "sha256-mGngP8kxfjGY9WbCqJUP1f+S9K/3q9KFBZjRyijDLq8=";
    };
  in
  {
    inherit version pname;
    inherit src;

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "reedline-0.25.0" = "sha256-J6AtZXoV8sRGQ75xq3ReRt3Hjz09bWLFzUnFDYCKg7s=";
      };
    };

    nativeBuildInputs = [ pkg-config ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ python3 ]
      ++ lib.optionals stdenv.isDarwin [ rustPlatform.bindgenHook ];

    buildInputs = [ openssl zstd ]
      ++ lib.optionals stdenv.isDarwin [ zlib libiconv Libsystem Security ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isLinux) [ xorg.libX11 ]
      ++ lib.optionals (withDefaultFeatures && stdenv.isDarwin) [ AppKit nghttp2 libgit2 ];

    buildFeatures = additionalFeatures [ (lib.optional withDefaultFeatures "default") ];

    # TODO investigate why tests are broken on darwin
    # failures show that tests try to write to paths
    # outside of TMPDIR
    doCheck = doCheck && !stdenv.isDarwin;

    checkPhase = ''
      runHook preCheck
      echo "Running cargo test"
      HOME=$TMPDIR cargo test
      runHook postCheck
      true
    '';

    meta = with lib; {
      description = "A modern shell written in Rust";
      homepage = "https://www.nushell.sh/";
      license = licenses.mit;
      maintainers = with maintainers; [ Br1ght0ne johntitor marsam ];
      mainProgram = "nu";
    };

    passthru = {
      shellPath = "/bin/nu";
      tests.version = testers.testVersion {
        package = nushell;
      };
      updateScript = nix-update-script { };
    };
  }
)
