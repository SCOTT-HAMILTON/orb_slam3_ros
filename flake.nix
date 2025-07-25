{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";  # IMPORTANT!!!
    orb-slam3-flake = {
      # url = "git+file:/home/scott/GIT/orb_slam3";
      url = "github:SCOTT-HAMILTON//orb_slam3";
      inputs.nixpkgs.follows = "nix-ros-overlay/nixpkgs";  # IMPORTANT!!!
    };
  };
  outputs = { self, nix-ros-overlay, nixpkgs, orb-slam3-flake }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
        pangolin = pkgs.rosPackages.noetic.callPackage ./pangolin/package.nix { };
      in {
        packages.default = pkgs.rosPackages.noetic.callPackage ./package.nix {
          inherit pangolin;
          orb-slam3 = orb-slam3-flake.packages.${system}.default;
        };
      });
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
