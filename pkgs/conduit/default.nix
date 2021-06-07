{ stdenv, lib, rustPlatform, fetchFromGitLab
, pkgconfig
, openssl
}:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "conduit";
  version = metadata.rev;

  src = fetchFromGitLab {
    owner = "famedly";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Conduit is a simple, fast and reliable chat server powered by Matrix";
    homepage = "https://conduit.rs";
    license = licenses.asl20;
    maintainers = [ maintainers.colemickens ];
  };
}
