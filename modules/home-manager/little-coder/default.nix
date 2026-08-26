{ lib, config, pkgs, ... }:

# little-coder — a pi-based coding agent tuned for small local models.
# Not in nixpkgs; built from source. Requires node >= 22.19 at runtime (nodejs below).

let
  littleCoder = pkgs.buildNpmPackage {
    pname = "little-coder";
    version = "1.18.0";
    src = pkgs.fetchFromGitHub {
      owner = "itayinbarr";
      repo = "little-coder";
      rev = "c97e319ff99445ff0be68d799847a376e12bf231"; # main @ v1.18.0
      hash = "sha256-cTL4mUwLqIlSiDpW5LIA9kMaBfIOnNVEPV8x/t2GFr0=";
    };
    npmDepsHash = "sha256-DWcOORLE5nOCd0nMqiq5sO/0fllt4o2WkOG972giZ9E=";
    dontNpmBuild = true; # plain JS, no build step
    makeCacheWritable = true; # npm cache quirk fetching pi-tui
    env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };
in
{
  options.custom.little-coder.enable = lib.mkEnableOption "enable little-coder coding agent";

  config = lib.mkIf config.custom.little-coder.enable {
    home.packages = [ littleCoder ];
  };
}