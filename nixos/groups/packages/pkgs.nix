{ pkgs }:
{
  packages = with pkgs; [
    gitui
    vim
    wget
    fzf
    fastfetch
    amdgpu_top

    neovim
    gcc
    unzip
    clang-tools
    stylua
    tree-sitter
    luaPackages.tree-sitter-cli

    vulkan-tools
    mesa-demos

    vscodium
    direnv
    zed-editor

    virt-manager
    virtio-win
    spice-gtk
    dnsmasq
  ];
}
