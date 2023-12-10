{ lib
, fetchFromGitHub
, buildPythonPackage
, cmake
, gcc
, numpy
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "distm";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "jnclark";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KMzzkvDAwaOA/2yRe1t+0G8EW7+a8y+iACze3AtytLg=";
  };
  dontUseCmakeConfigure = true;
  checkInputs = [
    pytestCheckHook
  ];
  pythonImportsCheck = [
    "distm"
  ];
  nativeBuildInputs = [
    cmake
    gcc
  ];
  propagatedBuildInputs = [
    numpy
  ];
  meta = with lib; {
    homepage = "https://github.com/jnclark/distm";
    description = "A Python library to efficiently calculate two dimensional distance matrices with C++ and OpenMP.";
    license = licenses.mit;
  };
}
