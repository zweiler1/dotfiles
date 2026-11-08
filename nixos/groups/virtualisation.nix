{
  virtualisation = {
    libvirtd = {
      enable = true;

      # Enable TPM emulation (for Windows 11)
      qemu.swtpm.enable = true;
    };

    # Enable USB redirection
    spiceUSBRedirection.enable = true;
  };
}
