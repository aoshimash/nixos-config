{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  volumePopupPy = pkgs.writeText "volume-popup.py" ''
    import gi
    gi.require_version('Gtk', '3.0')
    gi.require_version('Gdk', '3.0')
    from gi.repository import Gtk, Gdk, GLib
    import subprocess
    import os
    import signal
    import sys

    PID_FILE = '/tmp/volume-popup.pid'


    def kill_existing():
        try:
            with open(PID_FILE) as f:
                pid = int(f.read().strip())
            os.kill(pid, signal.SIGTERM)
            return True
        except (FileNotFoundError, ValueError, ProcessLookupError):
            pass
        return False


    def get_volume():
        result = subprocess.run(
            ['wpctl', 'get-volume', '@DEFAULT_AUDIO_SINK@'],
            capture_output=True, text=True
        )
        parts = result.stdout.strip().split()
        return float(parts[1]) * 100


    def set_volume(value):
        subprocess.run([
            'wpctl', 'set-volume', '-l', '1.0',
            '@DEFAULT_AUDIO_SINK@', str(round(value / 100, 2))
        ])


    if kill_existing():
        try:
            os.remove(PID_FILE)
        except FileNotFoundError:
            pass
        sys.exit(0)

    with open(PID_FILE, 'w') as f:
        f.write(str(os.getpid()))

    GLib.set_prgname('volume-popup')

    win = Gtk.Window(title='Volume')
    win.set_default_size(300, -1)
    win.set_decorated(False)
    win.set_resizable(False)

    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
    box.set_margin_start(10)
    box.set_margin_end(10)
    box.set_margin_top(8)
    box.set_margin_bottom(8)

    adj = Gtk.Adjustment(
        value=get_volume(), lower=0, upper=100,
        step_increment=1, page_increment=5
    )
    scale = Gtk.Scale(
        orientation=Gtk.Orientation.HORIZONTAL,
        adjustment=adj
    )
    scale.set_digits(0)
    scale.set_value_pos(Gtk.PositionType.RIGHT)
    scale.connect('value-changed', lambda s: set_volume(s.get_value()))

    box.add(scale)
    win.add(box)


    def quit_app(*args):
        try:
            os.remove(PID_FILE)
        except OSError:
            pass
        Gtk.main_quit()
        return False


    def on_key_press(widget, event):
        if event.keyval == Gdk.KEY_Escape:
            quit_app()
            return True
        return False


    win.connect('destroy', lambda w: quit_app())
    win.connect('focus-out-event', lambda w, e: quit_app())
    win.connect('key-press-event', on_key_press)
    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, quit_app)

    win.show_all()
    Gtk.main()
  '';

  giTypelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0" (
    with pkgs;
    [
      gobject-introspection
      gtk3
      glib
      pango
      gdk-pixbuf
      harfbuzz
    ]
  );

  volumePopup = pkgs.writeShellScript "volume-popup" ''
    export GI_TYPELIB_PATH="${giTypelibPath}"
    exec ${python}/bin/python3 ${volumePopupPy}
  '';
in
{
  home.packages = [ pkgs.pavucontrol ];

  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "HackGen35 Console NF", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 10px;
        min-width: 24px;
        color: #a6adc8;
        background: rgba(69, 71, 90, 0.5);
        margin: 4px 2px;
        border-radius: 4px;
        border: none;
      }

      #workspaces button.visible {
        color: #cdd6f4;
        border-bottom: 2px solid #585b70;
      }

      #workspaces button.active {
        color: #cdd6f4;
        background: rgba(137, 180, 250, 0.25);
        border-bottom: 2px solid #89b4fa;
      }

      #clock,
      #network,
      #pulseaudio,
      #bluetooth,
      #tray,
      #custom-power {
        padding: 0 10px;
      }

      #custom-power {
        color: #f38ba8;
      }

      #custom-power:hover {
        color: #cdd6f4;
        background: rgba(243, 139, 168, 0.25);
        border-radius: 4px;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "pulseaudio"
          "bluetooth"
          "tray"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{windows}";
          format-window-separator = " ";
          window-rewrite-default = "󰏗";
          window-rewrite = {
            "com.mitchellh.ghostty" = "󰆍";
            "firefox" = "󰈹";
            "google-chrome" = "󰊯";
            "chromium" = "󰊯";
            "code" = "󰨞";
            "Bitwarden" = "󰌋";
            "Freelens" = "󰠳";
            "discord" = "󰙯";
            "slack" = "󰒱";
            "nautilus" = "󰉋";
            "thunar" = "󰉋";
            "spotify" = "󰓇";
            "obsidian" = "󱓧";
          };
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "{:%A, %B %d, %Y}";
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  Muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "${volumePopup}";
          on-click-middle = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
          on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
        };

        bluetooth = {
          format = "󰂯 {status}";
          format-connected = "󰂱 {device_alias}";
          format-disabled = "󰂲";
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };

        "custom/power" = {
          format = "󰐥";
          tooltip = false;
          on-click = "wlogout";
        };
      };
    };
  };
}
