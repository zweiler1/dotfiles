{ pkgs }:
{
  packages = with pkgs; [
    gawk
    bash
    binutils
    coreutils
    curl
    diffutils
    findutils
    gnugrep
    gnumake
    jq
    openssh
    rsync
    gnused
    util-linux
    btrfs-progs
    killall
    htop
    rc #history
  ];
}
