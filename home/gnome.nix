{ pkgs, lib, ... }:
{
  # GNOME Shell extensions + close-workspace-windows script
  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-indicator
    (writeShellScriptBin "close-workspace-windows" ''
      # Close all windows on current workspace using GNOME Shell D-Bus API
      ${glib}/bin/gdbus call --session \
        --dest org.gnome.Shell \
        --object-path /org/gnome/Shell \
        --method org.gnome.Shell.Eval "
          const ws = global.workspace_manager.get_active_workspace();
          ws.list_windows().forEach(w => w.delete(global.get_current_time()));
        " > /dev/null 2>&1
    '')
  ];

  dconf.settings = {
    # Enable installed extensions
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "clipboard-indicator@tudmotu.com"
      ];
    };

    # Mutter: fractional scaling, disable SUPER overlay, multi-monitor workspaces
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
      # Disable SUPER key opening Activities (xremap uses SUPER for Mac-style shortcuts)
      overlay-key = "";
      # Workspaces span all displays (each monitor shows the same workspace)
      workspaces-only-on-primary = false;
      # Dynamic workspaces (GNOME auto-adds/removes empty workspaces)
      dynamic-workspaces = true;
    };

    # Input: Dvorak layout + IBus Mozc
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "us+dvorak"
        ])
        (lib.hm.gvariant.mkTuple [
          "ibus"
          "mozc-jp"
        ])
      ];
      xkb-options = [ ];
    };

    # Mouse: natural scroll
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };

    # Cursor theme
    "org/gnome/desktop/interface" = {
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = lib.hm.gvariant.mkInt32 20;
      color-scheme = "default";
    };

    # Window manager keybindings — migrate from Hyprland
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>w" ];
      toggle-fullscreen = [ "<Super>f" ];
      # Disable defaults that conflict with xremap SUPER usage
      panel-run-dialog = [ ];
      switch-applications = [ "<Alt>Tab" ];
      switch-applications-backward = [ "<Shift><Alt>Tab" ];
      # Workspace navigation: CTRL+Left/Right
      switch-to-workspace-left = [ "<Control>Left" ];
      switch-to-workspace-right = [ "<Control>Right" ];
      # Move window to workspace
      move-to-workspace-left = [ "<Shift><Control>Left" ];
      move-to-workspace-right = [ "<Shift><Control>Right" ];
    };

    # Disable SUPER+N launching Nth app from dash (conflicts with xremap SUPER usage)
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
      toggle-message-tray = [ ];
    };

    # Custom keybindings for terminal launch and close-all-windows
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    # SUPER+Return → launch Ghostty
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Launch Terminal";
      command = "ghostty";
      binding = "<Super>Return";
    };

    # SUPER+SHIFT+W → close all windows on workspace
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Close all windows on workspace";
      command = "close-workspace-windows";
      binding = "<Shift><Super>w";
    };
  };

  # IBus Mozc (Google Japanese Input equivalent)
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = [ pkgs.ibus-engines.mozc ];
  };
}
