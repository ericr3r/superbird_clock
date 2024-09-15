# Flake for building nerves system
# Use `nix develop .` for regular Nerves builds
# Use `nix develop .#fhs` for Nerves System builds
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        erlangVersion = "erlang_27";
        elixirVersion = "elixir_1_17";

        erlang = pkgs.beam.interpreters.${erlangVersion};
        elixir = pkgs.beam.packages.${erlangVersion}.${elixirVersion};

        commonPkgs = [
          elixir
          erlang
          pkgs.pkg-config
        ];


        supportPkgs = with pkgs; [
          atk
          brotli
          bzip2
          cairo
          coreutils
          dbus
          expat
          fontconfig
          freetype
          fribidi
          gcc
          gdk-pixbuf
          glfw-wayland
          glib
          glib
          graphite2
          gtk3
          harfbuzz
          lerc
          libGL
          libdatrie
          libdeflate
          libepoxy
          libffi
          libjpeg
          libmnl
          libpng
          libselinux
          libsepol
          libthai
          libtiff
          libtool
          libwebp
          libxkbcommon
          pango
          pcre2
          pixman
          util-linux
          wayland
          xorg.libX11
          xorg.libXau
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXdmcp
          xorg.libXext
          xorg.libXfixes
          xorg.libXft
          xorg.libXi
          xorg.libXinerama
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libxcb
          xorg.xorgproto
          zlib
          zstd
        ];

        # Scenic User Environment
        scenic = pkgs.buildFHSUserEnv {
          name = "fhs-shell";
          linkLibs = true;
          extraOutputsToInstall = [ "dev" ];
          targetPkgs = pkgs: commonPkgs ++ supportPkgs;
          runScript = pkgs.writeScript "init.sh" ''
            unset MIX_TARGET
            export FHS=true
            export SCENIC_LOCAL_TARGET=cairo-gtk
            export PKG_CONFIG_PATH=${pkgs.xorg.xorgproto}/share/pkgconfig:/usr/lib/pkgconfig
            exec zsh 
          '';
        };
      in
      {
        devShells.scenic = scenic.env;
      }
    );
}
