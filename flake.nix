{
  description = "vhs-decode dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    devenv.url = "github:cachix/devenv";
    jitterbug.url = "github:JuniorIsAJitterbug/nur-packages";
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "jitterbug.cachix.org-1:6GrV9s/TKZ07JuCWvHETRnt4yvuXayO8gYiM2o9mSVw="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://jitterbug.cachix.org"
    ];
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let

          jitterbug = inputs.jitterbug.packages.${pkgs.system};

          py-vhs-decode = pkgs.python3Packages.buildPythonApplication rec {
            pname = "py-vhs-decode";
            format = "setuptools";
            doCheck = false;

            version = "0.2.4";

            src = ./.;

            # workaround for no .git
            SETUPTOOLS_SCM_PRETEND_VERSION = version;

            buildInputs = with pkgs; [
              ffmpeg
            ];

            nativeBuildInputs = with pkgs.python3Packages; [
              setuptools_scm
            ];

            propagatedBuildInputs = with pkgs.python3Packages; [
              cython
              numpy
              jupyter
              numba
              pandas
              scipy
              matplotlib
              soundfile
              samplerate
              pyqt6
            ];
          };
        in
        {

          devenv.shells = {
            default = {
              name = "vhs-decode dev shell";

              languages.cplusplus.enable = true;

              packages = with pkgs; [
                pkg-config
                cmake
                ninja

                qt6.qttools
                qt6.wrapQtAppsHook
                jitterbug.qwt
                fftw
                ffmpeg
                #vhs-decode-tools
              ];

              scripts.build-ld-tools.exec = ''
                cmake . -B build -G Ninja \
                  -DCMAKE_CXX_FLAGS=-isystem\ ${jitterbug.qwt.dev}/include \
                  -DQWT_INCLUDE_DIR=${jitterbug.qwt.dev}/include
                  -DCMAKE_BUILD_TYPE=Release
                  -DUSE_QT_VERSION=6
                  -DBUILD_PYTHON=false                  

                cmake --build build -j8 --
              '';
            };
          };
        };
      flake = { };
    };
}
