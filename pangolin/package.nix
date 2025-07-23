{ lib, buildRosPackage, cmake, glew, python3, pkg-config, fetchFromGitHub }:
buildRosPackage {
  pname = "ros-noetic-pangolin";
  version = "0.6-fixed-nix";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Pangolin";
    rev = "v0.6-fixed-nix";
    sha256 = "sha256-4ilJdb3bKG5IkyrtIOD+P8w5bLnSc6DIV0bFqC4FqMc=";
  };

  buildType = "cmake";
  propagatedBuildInputs = [ cmake glew python3 ];
  nativeBuildInputs = [ cmake pkg-config ];

  meta = {
    description = "pangolin";
    license = with lib.licenses; [ mit ];
  };
}
