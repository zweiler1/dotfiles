{ pkgs }:
{
  packages = with pkgs; [
    gitui
    vim
    wget
    fzf
    eza
    fastfetch
    amdgpu_top
    qdirstat

    neovim
    gcc
    unzip
    clang-tools
    stylua
    tree-sitter
    luaPackages.tree-sitter-cli

    vulkan-tools
    mesa-demos
    ryzenadj # Needed to set max CPU temp to 85°C in the 'ryzenadj-tctl' service

    vscodium
    direnv
    zed-editor

    virtio-win
    spice-gtk
    dnsmasq
  ];
}
