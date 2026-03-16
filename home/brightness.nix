{ pkgs, ... }:
let
  brightnessScript = pkgs.writeShellScriptBin "brightness" ''
    # Control display brightness via wl-gammarelay-rs (D-Bus)
    # Usage: brightness [up|down]

    STEP="0.1"
    # D-Bus path uses underscores; monitor names: DP-6 -> DP_6
    MONITORS=("DP_6" "DP_8" "DP_9")

    get_brightness() {
      busctl --user get-property rs.wl-gammarelay \
        /outputs/DP_6 rs.wl-gammarelay.output Brightness 2>/dev/null \
        | awk '{print $2}'
    }

    set_all() {
      local val="$1"
      for mon in "''${MONITORS[@]}"; do
        busctl --user set-property rs.wl-gammarelay \
          /outputs/"$mon" rs.wl-gammarelay.output Brightness d "$val" &
      done
      wait
    }

    change() {
      local delta="$1"
      local cur
      cur=$(get_brightness)
      [ -z "$cur" ] && cur="1.0"
      local new
      new=$(awk -v c="$cur" -v d="$delta" 'BEGIN {
        v = c + d
        if (v < 0.1) v = 0.1
        if (v > 1.0) v = 1.0
        printf "%.1f", v
      }')
      set_all "$new"
      local pct
      pct=$(awk -v v="$new" 'BEGIN { printf "%d", v * 100 }')
      ${pkgs.libnotify}/bin/notify-send -t 1500 \
        -h string:x-canonical-private-synchronous:brightness \
        -u low "Brightness" "$pct%"
    }

    case "''${1:-}" in
      up)   change "+$STEP" ;;
      down) change "-$STEP" ;;
      *)    echo "Usage: brightness [up|down]"; exit 1 ;;
    esac
  '';
in
{
  home.packages = [
    pkgs.wl-gammarelay-rs
    brightnessScript
  ];
}
