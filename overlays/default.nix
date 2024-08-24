pythonVersions:

final: prev:

let
  applyPythonPackagesOverlays = { final, prev, pythonVersion }:
    let
      self = prev.${pythonVersion}.override {
        inherit self;
        packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
      };
    in
    self;
in

{

  pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
    (python-final: python-prev: {

      kmapper = python-prev.kmapper.overridePythonAttrs {
        version = "2.1.0";
        src = prev.fetchFromGitHub {
          owner = "scikit-tda";
          repo = "kepler-mapper";
          rev = "v2.1.0";
          hash = "sha256-i909J0yI8v8BqGbCkcjBAdA02Io+qpILdDkojZj0wv4=";
        };
        meta.broken = false;
      };

      distm = python-final.callPackage ../pkgs/distm { };

      ripser-plusplus = python-final.callPackage ../pkgs/ripser-plusplus { };

      ripser-plusplus-arbitrary-simplex = python-final.ripser-plusplus.overridePythonAttrs {
        pname = "ripser-plusplus-arbitrary-simplex";
        version = "2023-07-22";
        src = prev.fetchFromGitHub {
          owner = "jnclark";
          repo = "ripser-plusplus";
          rev = "main";
          hash = "sha256-IZ5KeQR9XcmVz9Kx9+TSnvZU23fxiYhFN9Cy2x717Kw=";
        };
        meta.homepage = "https://github.com/jnclark/ripser-plusplus";
      };

    })
  ];

} // prev.lib.attrsets.mergeAttrsList (prev.lib.lists.forEach pythonVersions (pyVer:
  ({
    "${pyVer}" = applyPythonPackagesOverlays { pythonVersion = pyVer; inherit final; inherit prev; };
    "${pyVer}Packages" = final."${pyVer}".pkgs;
  })
))
