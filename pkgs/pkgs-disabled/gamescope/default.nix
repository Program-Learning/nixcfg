{ stdenv
, fetchFromGitHub
, meson
, pkg-config
, ninja
, xorg
, libdrm
, vulkan-loader
, vulkan-headers
, wayland
, wayland-protocols
, libxkbcommon
, libcap
, SDL2
, pipewire
, udev
, pixman
, libinput
, seatd
, xwayland
, glslang
, stb
, wlroots
, libliftoff
, hwdata
, vkroots
, libdisplay-info
, lib
, makeBinaryWrapper
}:
let
  metadata = import ./metadata.nix;
  pname = "gamescope";
  version = metadata.rev;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Plagman";
    repo = "gamescope";
    inherit (metadata) rev hash;
  };

  patches = [ ./use-pkgconfig.patch ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    makeBinaryWrapper
  ];

  buildInputs = [
    xorg.libXdamage
    xorg.libXcomposite
    xorg.libXrender
    xorg.libXext
    xorg.libXxf86vm
    xorg.libXtst
    xorg.libXres
    xorg.libXi
    libdrm
    libliftoff
    hwdata
    vkroots
    libdisplay-info
    vulkan-loader
    vulkan-headers
    glslang
    SDL2
    wayland
    wayland-protocols
    wlroots
    xwayland
    seatd
    libinput
    libxkbcommon
    udev
    pixman
    pipewire
    libcap
    stb
  ];

  # --debug-layers flag expects these in the path
  postInstall = ''
    wrapProgram "$out/bin/gamescope" \
     --prefix PATH : ${with xorg; lib.makeBinPath [xprop xwininfo]}
  '';

  meta = with lib; {
    description = "SteamOS session compositing window manager";
    homepage = "https://github.com/Plagman/gamescope";
    license = licenses.bsd2;
    maintainers = with maintainers; [ nrdxp zhaofengli ];
    platforms = platforms.linux;
  };
}