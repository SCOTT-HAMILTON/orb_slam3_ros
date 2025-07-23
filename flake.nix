{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";  # IMPORTANT!!!
    pangolin-flake = {
      url = "git+file:/home/scott/GIT/test/ORB_SLAM3_ROS/Pangolin";
      inputs.nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    };
  };
  outputs = { self, nix-ros-overlay, nixpkgs, pangolin-flake }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
      in {
        packages.default = pkgs.rosPackages.noetic.callPackage ./package.nix {
          pangolin = pangolin-flake.packages.${system}.default;
        };
      });
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
