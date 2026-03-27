{ ... }:
{
  catppuccin.mako.enable = true;

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      anchor = "top-right";
      border-radius = 8;
    };
  };
}
