{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages =
      epkgs: with epkgs; [
        # Theme
        dracula-theme

        # Project management
        projectile

        # Git
        magit
        diff-hl

        # Key discoverability
        which-key

        # Minibuffer completion
        vertico
        orderless
        marginalia
        consult

        # Code completion
        corfu

        # File tree
        treemacs

        # Mode line
        doom-modeline
        nerd-icons

        # Clipboard (supports wl-clipboard for Wayland)
        xclip
      ];
    extraConfig = ''
      ;; Font: HackGen35 Console NF 12pt (consistent with Ghostty terminal)
      (set-face-attribute 'default nil :family "HackGen35 Console NF" :height 120)

      ;; use-package (built into Emacs 29+)
      (require 'use-package)

      ;; Theme
      (use-package dracula-theme
        :config
        (load-theme 'dracula t))

      ;; Which-key: show available keybindings after prefix
      (use-package which-key
        :config
        (which-key-mode))

      ;; Project management
      (use-package projectile
        :config
        (projectile-mode +1)
        :bind-keymap
        ("C-c p" . projectile-command-map))

      ;; Vertico: vertical minibuffer completion
      (use-package vertico
        :config
        (vertico-mode))

      ;; Orderless: flexible completion matching
      (use-package orderless
        :custom
        (completion-styles '(orderless basic)))

      ;; Marginalia: completion annotations
      (use-package marginalia
        :config
        (marginalia-mode))

      ;; Consult: enhanced search and navigation commands
      (use-package consult
        :bind
        (("C-s" . consult-line)
         ("C-x b" . consult-buffer)))

      ;; Corfu: in-buffer code completion
      (use-package corfu
        :custom
        (corfu-auto t)
        :config
        (global-corfu-mode))

      ;; Magit: Git interface
      (use-package magit
        :bind ("C-x g" . magit-status))

      ;; diff-hl: inline Git diffs in gutter
      (use-package diff-hl
        :config
        (global-diff-hl-mode)
        (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
        (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

      ;; Treemacs: file tree sidebar
      (use-package treemacs
        :bind ("C-x t t" . treemacs))

      ;; Doom modeline: modern status bar
      (use-package doom-modeline
        :config
        (doom-modeline-mode 1))

      ;; Nerd icons (used by doom-modeline)
      (use-package nerd-icons)

      ;; Clipboard: integrates with wl-copy/wl-paste on Wayland
      (use-package xclip
        :config
        (xclip-mode 1))
    '';
  };
}
