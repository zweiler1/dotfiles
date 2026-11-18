{
  pkgs,
  ...
}:

{
  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        # Enable TPM emulation (for Windows 11)
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [
          virtiofsd
        ];
      };
    };

    # Enable USB redirection
    spiceUSBRedirection.enable = true;
  };
}
