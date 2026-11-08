{ pkgs, ... }:
{
  systemd = {
    tmpfiles.rules = [
      # Fix asusd as it requires the /etc/asusd dir to be present
      "d /etc/asusd 0755 root root -"
    ];

    user.services.rebuild-ksycoca = {
      description = "Rebuild KDE ksycoca cache (MIME / service types)";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "rebuild-ksycoca" ''
          rm -f "$HOME"/.cache/ksycoca6_*
          ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
        '';
      };
    };

    services.asus-shutdown = {
      overrideStrategy = "asDropinIfExists";

      serviceConfig.ReadWritePaths = [
        "/sys/devices/pci0000:00/0000:00:08.1/0000:77:00.0/uma/carveout"
      ];
    };
  };
}
