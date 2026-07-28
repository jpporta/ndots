{
  lib,
  config,
  pkgs,
  ...
}: let
  bw = pkgs.writeShellApplication {
    name = "bw";
    runtimeInputs = with pkgs; [ rbw fzf wl-clipboard libnotify ];
    text = ''
      set -euo pipefail
      cmd="$(basename "$0")"

      entry="$(rbw list --fields=id,name,user --format=tsv \
        | fzf --with-nth=2.. --delimiter=$'\t')"
      [ -z "$entry" ] && exit 0

      id="$(printf '%s' "$entry" | cut -f1)"

      case "$cmd" in
        bwc) val="$(rbw code "$id")"                          ;;
        bwu) val="$(rbw get --field username "$id")"          ;;
        bwp) val="$(rbw get "$id")"                           ;;
        *)   exit 1                                            ;;
      esac

      printf '%s' "$val" | wl-copy
      notify-send -t 1200 "bw: copied $cmd"
    '';
  };
in {
  options.custom = {
    bitwarden.enable = lib.mkEnableOption "enable bitwarden - CLI password manager";
  };

  config = lib.mkIf config.custom.bitwarden.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = "me@joaoporta.com";
        lock_timeout = 7200;
        pinentry = pkgs.pinentry-gnome3;
        base_url = "https://pass.joaoporta.com";
      };
    };

    home.packages =
      let mkBin = name:
        pkgs.symlinkJoin {
          inherit name;
          paths = [ bw ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = "ln -sf ${bw}/bin/bw $out/bin/${name}";
        };
      in
        builtins.map mkBin [ "bwp" "bwc" "bwu" ];
  };
}
