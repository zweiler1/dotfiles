{ pkgs }:
{
  hardware = {
    # Needed by noctalia
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
        vulkan-loader
        vulkan-validation-layers
        libva
        libvdpau

        rocmPackages.clr.icd
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        mesa
        vulkan-loader
      ];
    };

    amdgpu.initrd.enable = true;
  };
}
