function fish_greeting
    fastfetch
end

# Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

set -x BUN_INSTALL "$HOME/.bun"

# Fish command history
function history
    builtin history --show-time='%F %T ' $argv
end

function backup --argument filename
    cp $filename $filename.bak
end

alias clear 'printf "\033[2J\033[3J\033[1;1H"'
alias claer "clear"

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
    # proptest -M amdgpu -D /dev/dri/card1 400 connector 401 2
    # proptest -M amdgpu -D /dev/dri/card2 400 connector 401 2
    # LTS Kernel (6.18)
    # proptest -M amdgpu -D /dev/dri/card1 103 connector 104 2
    # proptest -M amdgpu -D /dev/dri/card2 103 connector 104 2

    # Discrete
    # proptest -M amdgpu -D /dev/dri/card0 400 connector 401 2
    # proptest -M amdgpu -D /dev/dri/card1 400 connector 401 2
end

# Enable vi mode
fish_vi_key_bindings

# Define cursor shapes for Vi mode
set -g fish_cursor_default block
set -g fish_cursor_insert line blink
set -g fish_cursor_replace_one block
set -g fish_cursor_visual block


# Append common directories for executable files to $PATH
fish_add_path ~/.local/bin ~/.cargo/bin

# Add ~/$BUN_INSTALL/bin to PATH
if test -d "$BUN_INSTALL/bin"
    fish_add_path "$BUN_INSTALL/bin"
end

# Add ~/env/flint/flintc/zig-out/bin to PATH
if test -d "$HOME/env/flint/flintc/zig-out/bin"
    fish_add_path "$HOME/env/flint/flintc/zig-out/bin"
end

# Add ~/env/flint/flint/zig-out/bin to PATH
if test -d "$HOME/env/flint/flint/zig-out/bin"
    fish_add_path "$HOME/env/flint/flint/zig-out/bin"
end

# Add ~/env/flint/fip-c/zig-out/bin to PATH
if test -d "$HOME/env/flint/fip-c/zig-out/bin"
    fish_add_path "$HOME/env/flint/fip-c/zig-out/bin"
end

# Add ~/env/flint/clape to PATH
if test -d "$HOME/env/flint/clape"
    fish_add_path "$HOME/env/flint/clape"
end


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/zweiler1/.opam/opam-init/init.fish' && source '/home/zweiler1/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration
