{ config, lib, pkgs, ... }:

let
  cfg = config.custom.dict;

  # Offline dictionary lookup via sdcv, renders HTML articles to plain text.
  # Colorized on a TTY; byte-identical plain output when piped.
  dict = pkgs.writeShellApplication {
    name = "dict";
    runtimeInputs = with pkgs; [ sdcv gnused pandoc coreutils ];
    text = ''
      [ $# -eq 0 ] && { echo "usage: dict <word>"; exit 1; }

      # @@ marks entry-header lines (former "-->" lines) for the color pass
      mark=""
      if [ -t 1 ]; then mark=@@; fi

      { sdcv -n "$@" 2>/dev/null || true; } |
        sed -e 's/^Found \(.*\)$/Found \1<br>/' \
            -e "s/^-->\\(.*\\)$/<b>''${mark}\\1<\\/b><br>/" |
        pandoc -f html -t plain --wrap=none |
        if [ -n "$mark" ]; then
          sed -E \
            -e 's/^(Found .*items.*)$/\x1b[2m\1\x1b[0m/' \
            -e 's/^@@(.*)$/\x1b[1;35m\1\x1b[0m/' \
            -e 's/^([A-Z][a-zA-Z]*)$/\x1b[1;36m\1\x1b[0m/' \
            -e 's/^([A-Z]{2,3}: .*)$/\x1b[36m\1\x1b[0m/' \
            -e 's/^([[:space:]]*)([0-9]+\.)[[:space:]]/\1\x1b[1;33m\2\x1b[0m /' \
            -e 's/^([[:space:]]*)([a-z]+\.)([[:space:]])/\1\x1b[2m\2\x1b[0m\3/'
        else
          cat
        fi
    '';
  };
in
{
  options.custom.dict.enable = lib.mkEnableOption "offline sdcv dictionary lookup with the dict helper script";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.sdcv
      dict
    ];
  };
}
