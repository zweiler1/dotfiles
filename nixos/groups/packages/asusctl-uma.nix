{ pkgs }:

let
  amdgpuUmaMode = pkgs.writeShellScriptBin "amdgpu-uma-mode" ''
    #!/usr/bin/env bash

    log() {
        logger -t amdgpu-uma-mode -- "$1"
    }

    DGPU_DISABLE="''${1:-}"
    GPU_MUX_MODE="''${2:-}"

    if [[ ! "$DGPU_DISABLE" =~ ^[01]$ || ! "$GPU_MUX_MODE" =~ ^[01]$ ]]; then
        log "Invalid or incomplete GPU mode arguments; leaving UMA unchanged."
        exit 0
    fi

    case "''${DGPU_DISABLE:-}:''${GPU_MUX_MODE:-}" in
        1:1)
            UMA_INDEX=2
            MODE="Integrated"
            ;;
        0:1)
            UMA_INDEX=1
            MODE="Hybrid"
            ;;
        0:0)
            UMA_INDEX=1
            MODE="Ultimate"
            ;;
        *)
            log "No recognized complete GPU-mode change queued; leaving UMA unchanged."
            exit 0
            ;;
    esac

    # Find the UMA sysfs attribute instead of just assuming card1
    shopt -s nullglob
    UMA_PATHS=(/sys/class/drm/card*/device/uma/carveout)

    if [[ ''${#UMA_PATHS[@]} -ne 1 ]]; then
        log "Expected exactly one UMA carveout attribute; found ''${#UMA_PATHS[@]}."
        exit 0
    fi

    UMA_PATH="''${UMA_PATHS[0]}"
    CURRENT_INDEX="$(< "$UMA_PATH")"

    if [[ "$CURRENT_INDEX" == "$UMA_INDEX" ]]; then
        log "UMA already configured for $MODE (index $UMA_INDEX); no change needed."
        exit 0
    fi

    if printf '%s\n' "$UMA_INDEX" > "$UMA_PATH"; then
        log "Selected UMA index $UMA_INDEX for queued $MODE mode."
    else
        log "Failed to select UMA index $UMA_INDEX for queued $MODE mode."
    fi

    exit 0
  '';
in
pkgs.asusctl.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    ../../patches/asus-shutdown-uma.patch
  ];

  # Include the helper in the asusctl package itself
  postInstall = (old.postInstall or "") + ''
    install -Dm755 ${amdgpuUmaMode}/bin/amdgpu-uma-mode "$out/bin/amdgpu-uma-mode"
  '';
})
