{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom = {
    hyprsunset.enable = lib.mkEnableOption "enable hyprsunset - eye saver";
  };

  config = lib.mkIf config.custom.hyprsunset.enable {
    services.hyprsunset = {
      enable = true;
      settings = {
        max-gamma = 150;
        # profile = [
        #   {
        #     time = "7:30";
        #     identity = true;
        #   }
        #   {
        #     time = "18:00";
        #     temperature = 4000;
        #     gamma = 1;
        #   }
        #   {
        #     time = "20:00";
        #     temperature = 4000;
        #     gamma = 0.8;
        #   }
        # ];
      };
    };
  };
}
