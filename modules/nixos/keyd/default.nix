{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.keyd;
  defaultRemap = {
    main = {
      capslock = "overload(control, esc)";
    };
  };
  defaultNoop = {
    main = { };
  };
in
{
  options.custom.keyd = {
    enable = lib.mkEnableOption "keyd (system-wide key remapping daemon)";

    # Vendor:product IDs that get the capslock overload. See `keyd monitor`.
    internalIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "1ea7:0907" ];
      example = [ "1ea7:0907" ];
      description = "Device IDs to apply the capslock overload to (matched against keyd's id list).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards = {
        internal = {
          ids = cfg.internalIds;
          settings = defaultRemap;
        };
        default = {
          ids = [ "*" ];
          settings = defaultNoop;
        };
      };
    };
  };
}
