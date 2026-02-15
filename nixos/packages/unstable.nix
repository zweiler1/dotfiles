{ pkgs ? import <nixos-unstable> { } }:
{
  packages = with pkgs; [
    noctalia-shell
  ];
}
