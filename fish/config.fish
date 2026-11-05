source /usr/share/cachyos-fish-config/cachyos-config.fish

if status is-login
    # modetest -M amdgpu -D /dev/dri/card1 -c
    # eDP-2: nothing
    # DP2: 401
    # DP3: 408
    # DP4: 414
    # DP5: 420
    # DP6: 426

    # Hybrid
    # New Kernel (7.2) (no work 4k)
    proptest -M amdgpu -D /dev/dri/card1 400 connector 401 2
    proptest -M amdgpu -D /dev/dri/card2 400 connector 401 2
    # LTS Kernel (6.18)
    proptest -M amdgpu -D /dev/dri/card1 103 connector 104 2
    proptest -M amdgpu -D /dev/dri/card2 103 connector 104 2

    # Discrete
    # proptest -M amdgpu -D /dev/dri/card0 400 connector 401 2
    # proptest -M amdgpu -D /dev/dri/card1 400 connector 401 2
end

# overwrite greeting
# potentially disabling fastfetch
# function fish_greeting
#    # smth smth
# end

# Enable vi mode
fish_vi_key_bindings

# Define cursor shapes for Vi mode
set -g fish_cursor_default block
set -g fish_cursor_insert line blink
set -g fish_cursor_replace_one block
set -g fish_cursor_visual block

alias kvm-start='sudo virsh net-start default && sudo modprobe tun && sudo modprobe vhost_net'
alias yt-dlp-ogg='yt-dlp -x --audio-format vorbis' # --audio-quality 0
alias docker-start='sudo systemctl start docker.service'
alias cd..='cd ..'
alias grub-update='sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --removable && sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias restart-pipewire='systemctl restart --user pipewire wireplumber.service pipewire-pulse.service'
#alias cat='bat'
alias grep='grep --color=auto'
alias xterm='xterm -fg white -bg black'
alias TM='$HOME/.config/theme-manager/theme-manager'
alias TA='$HOME/.config/theme-manager/theme-applier'
alias TG='$HOME/.confog/theme-manager/theme-generator'
alias TC='$HOME/gitclones/theme-manager/copy-scripts'
alias clear='printf "\033[2J\033[3J\033[1;1H"'
alias wiki='$HOME/gitclones/Industrie40_Demonstrator_01/wiki.sh'
alias ij='env LC_ALL="de_AT.UTF-8" intellij-idea-ultimate-edition'
# alias ls='ls --hyperlink=always --color=auto'

alias pwr_now='asusctl profile get'
alias pwr_performance='asusctl profile set Performance'
alias pwr_balanced='asusctl profile set Balanced'
alias pwr_quiet='asusctl profile set Quiet'
alias gpu_now='supergfxctl -g'
alias gpu_list='supergfxctl -s'
alias gpu_hybrid='supergfxctl -m Hybrid && sudo reboot now'
alias gpu_integrated='supergfxctl -m Integrated && sudo reboot now'
alias gpu_dedicated='supergfxctl -m AsusMuxDgpu && sudo reboot now'
alias gamma='hyprctl hyprsunset gamma'

alias use_dgpu="DRI_PRIME=pci-0000_03_00_0"
alias use_igpu="DRI_PRIME=pci-0000_77_00_0"

alias nix-clean='nix-collect-garbage -d'

alias mount-nfs='sudo mount -t nfs zweilerserver.ddns.net:/srv /NFS'

set -x BUN_INSTALL "$HOME/.bun"

# Add ~/$BUN_INSTALL/bin to PATH
if test -d "$BUN_INSTALL/bin"
    if not contains -- "$BUN_INSTALL/bin" $PATH
        set -p PATH "$BUN_INSTALL/bin"
    end
end

# Add ~/env/flint/flintc/zig-out/bin to PATH
if test -d "$HOME/env/flint/flintc/zig-out/bin"
    if not contains -- "$HOME/env/flint/flintc/zig-out/bin" $PATH
        set -p PATH "$HOME/env/flint/flintc/zig-out/bin"
    end
end

# Add ~/env/flint/clape to PATH
if test -d "$HOME/env/flint/clape"
    if not contains -- "$HOME/env/flint/clape" $PATH
        set -p PATH "$HOME/env/flint/clape"
    end
end


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/zweiler1/.opam/opam-init/init.fish' && source '/home/zweiler1/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
