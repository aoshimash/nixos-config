{ pkgs, ... }:
{
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # Add user to scanner group
  users.users.aoshima.extraGroups = [ "scanner" ];
}
