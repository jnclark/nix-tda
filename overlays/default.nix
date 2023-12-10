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
        version = "unstable";
        src = prev.fetchFromGitHub {
          owner = "scikit-tda";
          repo = "kepler-mapper";
          rev = "master";
          hash = "sha256-ra3cBd5FtkMZbBqq+B37iEnc/1K627q59qhk8pzB6Vs=";
        };
        patches = [ ../pkgs/kepler-mapper/fix-tests.patch ];
        meta.broken = false;
      };

      distm = python-final.callPackage ../pkgs/distm { };

      pot = python-prev.pot.overridePythonAttrs (old: {
        #doCheck = false; # to supress a ton of errors
        disabledTests = old.disabledTests ++ [
          # More Fixture is not availible
          "test_bures_wasserstein_distance"
          "test_bures_wasserstein_mapping"
          "test_coot"
          "test_coot_log"
          "test_coot_raise_value_error"
          "test_coot_warmstart"
          "test_coot_with_linear_terms"
          "test_dmmot_monge_1dgrid_loss"
          "test_dmmot_monge_1dgrid_optimize"
          "test_empirical_bures_wasserstein_distance"
          "test_empirical_bures_wasserstein_mapping"
          "test_entropic_coot"
          "test_gaussian_gromov_wasserstein_distance"
          "test_gaussian_gromov_wasserstein_mapping"
          "test_generalised_free_support_barycenter_backends"
          "test_get_backend"
          "test_partial_solve_wasserstein"
          "test_partial_wasserstein"
          "test_solve"
          "test_solve_grid"
          "test_solve_not_implemented"
        ];
        disabledTestPaths = old.disabledTestPaths ++ [
          # More AttributeError: module pytest has no attribute skip_backend
          "test/test_1d_solver.py"
          "test/test_sliced.py"
        ];
      });
      gudhi = python-final.callPackage ../pkgs/gudhi { pot = python-final.pot; };

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

  python310 = applyPythonPackagesOverlays { pythonVersion = "python310"; inherit final; inherit prev; };
  python310Packages = final.python310.pkgs;

  python311 = applyPythonPackagesOverlays { pythonVersion = "python311"; inherit final; inherit prev; };
  python311Packages = final.python311.pkgs;

  python3 = applyPythonPackagesOverlays { pythonVersion = "python3"; inherit final; inherit prev; };
  python3Packages = final.python3.pkgs;

}
