{
  hardware = {
    # Update AMD CPU Microcode for security
    cpu.amd.updateMicrocode = true;

    # Enable OpenGL
    graphics.enable = true;

    # Enable bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
