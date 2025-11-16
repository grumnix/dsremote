{
  description = "Control and visualize Rigol® DS6000 or DS1000Z series oscilloscopes";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    dsremote-src.url = "gitlab:Teuniz/DSRemote";
    dsremote-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, dsremote-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = dsremote;

          dsremote = pkgs.stdenv.mkDerivation rec {
            pname = "dsremote";
            version = "0.42_2408061715";

            src = dsremote-src;

            postPatch = ''
                sed -i "s#/usr/#$out/#" dsremote.pro
                sed -i "s#/etc/#$out/etc/#" dsremote.pro

                # FIXME: No idea where _FORTIFY_SOURCE comes from
                sed -i "s/#error \"configuration error\"//" global.h
            '';

            nativeBuildInputs = [
              pkgs.qt5.wrapQtAppsHook
              pkgs.qt5.qmake
            ];

            buildInputs = [
              pkgs.qt5.qtbase
              pkgs.qt5.qttools
              # pkgs.fortify-headers
            ];

            meta = with pkgs.lib; {
              description = "Operate your Rigol oscilloscope from your Linux desktop.";

              longDescription = ''
                DSRemote is a program to control and visualize your
                Rigol® DS6000 or DS1000Z series oscilloscope from your
                Linux desktop via USB or LAN. It will probably work as
                well with the other series like DS2000A and DS4000
                series but I have no access to all those oscilloscopes
                so I can not test it. I tried to mimic the interface
                of the DS6000 series. It's a work in progress but the
                basic controls are working. Live signals can be
                viewed, screenshots can be made and waveform data can
                be saved. There's no manual yet, but it's pretty
                straight forward.
              '';
              homepage = "https://www.teuniz.net/DSRemote/";
              license = licenses.gpl3Plus;
              platforms = platforms.all;
            };
          };
        };
      }
    );
}
