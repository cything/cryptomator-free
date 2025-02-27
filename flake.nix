{
  description = "build cryptomator";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        devShells.default =
        let
          androidPkgs = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [ "34" ];
            buildToolsVersions = [ "34.0.0" ];
            includeEmulator = false;
            includeSystemImages = false;
            includeNDK = false;
          };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            androidPkgs.androidsdk
            jdk17
          ];
          shellHook = ''
            export ANDROID_HOME="${androidPkgs.androidsdk}/libexec/android-sdk";
          '';
        };
      };
    };
}
