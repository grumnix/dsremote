{
  description = "Control and visualize Rigol® DS6000 or DS1000Z series oscilloscopes";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    dsremote-src.url = "gitlab:Teuniz/DSRemote";
    dsremote-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, dsremote-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          dsremote = pkgs.stdenv.mkDerivation rec {
            pname = "dsremote";
            version = "0.0";
            src = dsremote-src;
            postPatch = ''
                sed -i "s#/usr/#$out/#" dsremote.pro
                sed -i "s#/etc/#$out/etc/#" dsremote.pro
            '';
            nativeBuildInputs = [
              pkgs.qt5.wrapQtAppsHook
              pkgs.qt5.qmake
            ];
            buildInputs = [
              pkgs.qt5.qtbase
              pkgs.qt5.qttools
            ];
          };
        };
        defaultPackage = packages.dsremote;
      }
    );
}
