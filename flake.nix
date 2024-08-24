{
  description = "A collection of packages and utilities built with Nix for Topological Data Analysis and Persistent Homology";

  inputs = {

    nixpkgs = {
      url = github:nixos/nixpkgs/nixos-24.05;
    };

  };

  outputs =
    { self
    , nixpkgs
    , ...
    }:
    let
      system = "x86_64-linux";
      pythonVersions = [ "python3" "python311" "python312" ];
      LD_LIBRARY_PATH = "/run/opengl-driver/lib:/usr/lib/x86_64-linux-gnu/nvidia/current:" + (pkgs.lib.makeLibraryPath [
        pkgs.cudaPackages.cudatoolkit
      ]);
      version = builtins.substring 0 8 self.lastModifiedDate;

      pkgs = import nixpkgs {
        inherit system;
        config = {
          # must allow the following unfree packages to utilize CUDA:
          # cudatoolkit
          allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
            "cuda-merged"
            "cuda_cccl"
            "cuda_cudart"
            "cuda_cuobjdump"
            "cuda_cupti"
            "cuda_cuxxfilt"
            "cuda_gdb"
            "cuda_nvcc"
            "cuda_nvdisasm"
            "cuda_nvml_dev"
            "cuda_nvprune"
            "cuda_nvrtc"
            "cuda_nvtx"
            "cuda_profiler_api"
            "cuda_sanitizer_api"
            "cudatoolkit"
            "libcublas"
            "libcufft"
            "libcurand"
            "libcusolver"
            "libcusparse"
            "libnpp"
            "libnvjitlink"
          ];
        };
        overlays = [ self.overlays.default ];
      };
      lib = pkgs.lib;

      usefulPythonPackages = pythonVersion:
        with pkgs."${pythonVersion}Packages"; [
          jupyter
          jupyterlab
          igraph
          ipywidgets
          matplotlib
          networkx
          pandas
          plotly
          scikit-learn
          umap-learn
          gudhi
          pot
          # packages from this flake's overlay
          distm
          kmapper
        ];

      usefulPackages = with pkgs; [
        cytoscape
      ];

      pythonPackageGen = pythonVersion:
        {

          "distm-${pythonVersion}" = pkgs."${pythonVersion}".pkgs.distm;
          "kmapper-${pythonVersion}" = pkgs."${pythonVersion}".pkgs.kmapper;
          "ripser-plusplus-${pythonVersion}" = pkgs."${pythonVersion}".pkgs.ripser-plusplus;
          "ripser-plusplus-arbitrary-simplex-${pythonVersion}" = pkgs."${pythonVersion}".pkgs.ripser-plusplus-arbitrary-simplex;

        };

      pythonShellGen = pythonVersion:
        {

          "useful-tools-${pythonVersion}" = pkgs.mkShell {
            name = "useful-tools-${pythonVersion}";
            buildInputs = [
              (usefulPythonPackages pythonVersion)
              usefulPackages
            ];
          };

          "ripser-plusplus-${pythonVersion}" = pkgs.mkShell {
            name = "ripser++-${pythonVersion}";
            buildInputs = [
              (usefulPythonPackages pythonVersion)
              usefulPackages
              pkgs."${pythonVersion}".pkgs.ripser-plusplus
            ];
            LD_LIBRARY_PATH = "${LD_LIBRARY_PATH}";
          };

          "ripser-plusplus-arbitrary-simplex-${pythonVersion}" = pkgs.mkShell {
            name = "ripser++-arbitrary-simplex-${pythonVersion}";
            buildInputs = [
              (usefulPythonPackages pythonVersion)
              usefulPackages
              pkgs."${pythonVersion}".pkgs.ripser-plusplus-arbitrary-simplex
            ];
            LD_LIBRARY_PATH = "${LD_LIBRARY_PATH}";
          };

        };

    in
    {

      overlays.default = (import ./overlays) pythonVersions;

      packages.${system} = lib.attrsets.mergeAttrsList (lib.lists.forEach pythonVersions (pyVer:
        (pythonPackageGen pyVer)
      ));

      devShells.${system} = {

        default = self.devShells.${system}.ripser-plusplus-arbitrary-simplex-python3;

      } // lib.attrsets.mergeAttrsList (lib.lists.forEach pythonVersions (pyVer:
        (pythonShellGen pyVer)
      ));

      hydraJobs = {
        inherit (self)
          packages devShells;
      };

      formatter.${system} = pkgs.nixpkgs-fmt;

    };
}
