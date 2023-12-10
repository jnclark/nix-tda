# This is an expansion/modification of the file in
# https://github.com/NixOS/nixpkgs
# nixpkgs/pkgs/development/python-modules/gudhi/default.nix

{ lib
, fetchFromGitHub
, buildPythonPackage
, cmake
, boost
, eigen
, gmp
, cgal_5  # see https://github.com/NixOS/nixpkgs/pull/94875 about cgal
, mpfr
, tbb
, numpy
, cython
, pybind11
, matplotlib
, scipy
, pytest
, tensorflow
, keras
, joblib
, scikit-learn
, pot
, enableTBB ? false
}:

buildPythonPackage rec {
  pname = "gudhi";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "GUDHI";
    repo = "gudhi-devel";
    rev = "tags/gudhi-release-${version}";
    fetchSubmodules = true;
    hash = "sha256-f2ajy4muG9vuf4JarGWZmdk/LF9OYd2KLSaGyY6BQrY=";
  };

  patches = [ ./remove_explicit_PYTHONPATH.patch ];

  nativeBuildInputs = [ cmake numpy cython pybind11 matplotlib ];
  buildInputs = [ boost eigen gmp cgal_5 mpfr ]
    ++ lib.optionals enableTBB [ tbb ];
  propagatedBuildInputs = [ numpy scipy ];
  nativeCheckInputs = [
    pytest
    scikit-learn
    joblib
    matplotlib
    pot
    tensorflow
    keras
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DWITH_GUDHI_PYTHON=ON"
    "-DPython_ADDITIONAL_VERSIONS=3"
  ];

  preBuild = ''
    cd src/python
  '';

  checkPhase = ''
    rm -r gudhi
    ${cmake}/bin/ctest --output-on-failure
  '';

  pythonImportsCheck = [
    "gudhi"
    "gudhi.hera"
    "gudhi.point_cloud"
    "gudhi.clustering"
    "gudhi.tensorflow"
    "gudhi.datasets"
    "gudhi.representations"
    "gudhi.sklearn"
    "gudhi.wasserstein"
  ];

  meta = {
    description = "Library for Computational Topology and Topological Data Analysis (TDA)";
    homepage = "https://gudhi.inria.fr/python/latest/";
    downloadPage = "https://github.com/GUDHI/gudhi-devel";
    license = with lib.licenses; [ mit gpl3 ];
  };
}
