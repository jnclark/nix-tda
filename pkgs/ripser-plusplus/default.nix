{ lib
, fetchFromGitHub
, buildPythonPackage
, cmake
, gcc
, numpy
, scipy
, cudaPackages
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "ripser-plusplus";
  version = "2023-03-16";
  gitHash = "30243c0c752de26d7fdf6e41f08bf7b840ca4744";
  src = fetchFromGitHub {
    owner = "simonzhang00";
    repo = pname;
    rev = gitHash;
    # fetchSubmodules = true;
    # not neccesary, as the submodule is only used to reproduce the
    # paper's experiments, and not for any functional component of the
    # package
    hash = "sha256-5txo6YClNTqlWqHsnXQWJtrBWL174tW3IwBPfdzA24U=";
  };
  doCheck = false;
  pythonImportsCheck = [
    "ripserplusplus"
  ];
  dontUseCmakeConfigure = true;
  nativeBuildInputs = [
    cmake
    gcc #11
  ];
  propagatedBuildInputs = [
    numpy
    scipy
    cudaPackages.cudatoolkit
  ];
  patches = [ ./cmake-build.patch ];
  meta = with lib; {
    homepage = "https://github.com/simonzhang00/ripser-plusplus";
    description = "Ripser++: GPU-accelerated computation of Vietoris-Rips persistence barcodes";
    license = licenses.mit;
  };
}
