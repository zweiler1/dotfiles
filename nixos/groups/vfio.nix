{
  pkgs,
  ...
}:

{
  # Include ASUS WMI and its module dependencies in the initrd.
  # The module is loaded manually by the service below.
  boot.initrd.availableKernelModules = [
    "asus_nb_wmi"
    "vfio"
    "vfio_pci"
    "vfio_iommu_type1"
  ];

  boot.initrd.systemd.services.vfio-gpu-mode-detect = {
    description = "Detect ASUS GPU mode before graphics drivers initialize";

    # Start before the normal initrd module loading and udev coldplug.
    wantedBy = [
      "systemd-modules-load.service"
      "systemd-udevd-kernel.socket"
      "systemd-udevd-control.socket"
      "systemd-udevd-varlink.socket"
    ];

    before = [
      "systemd-modules-load.service"
      "systemd-udevd-kernel.socket"
      "systemd-udevd-control.socket"
      "systemd-udevd-varlink.socket"
      "systemd-udevd.service"
      "systemd-udev-trigger.service"
    ];

    # This is an early-boot service. Do not inherit the normal
    # dependency on basic.target.
    unitConfig.DefaultDependencies = false;

    path = [
      pkgs.kmod
    ];

    serviceConfig.Type = "oneshot";

    script = ''
      set -eu

      echo "Loading ASUS WMI driver..."
      modprobe asus_nb_wmi

      WMI=/sys/devices/platform/asus-nb-wmi

      if [ ! -r "$WMI/gpu_mux_mode" ] ||
         [ ! -r "$WMI/dgpu_disable" ]; then
        echo "ERROR: ASUS GPU mode attributes are unavailable."
        exit 1
      fi

      IFS= read -r GPU_MUX_MODE < "$WMI/gpu_mux_mode"
      IFS= read -r DGPU_DISABLE < "$WMI/dgpu_disable"

      case "$GPU_MUX_MODE:$DGPU_DISABLE" in
        1:1)
          MODE=integrated
          ;;
        1:0)
          MODE=hybrid
          ;;
        0:0)
          MODE=ultimate
          ;;
        *)
          echo "ERROR: Unknown ASUS GPU configuration:"
          echo "gpu_mux_mode=$GPU_MUX_MODE"
          echo "dgpu_disable=$DGPU_DISABLE"
          exit 1
          ;;
      esac

      echo "Detected ASUS GPU mode: $MODE"
      echo "gpu_mux_mode=$GPU_MUX_MODE"
      echo "dgpu_disable=$DGPU_DISABLE"
    '';
  };

  boot.initrd.systemd.services.vfio-gpu-bind = {
    description = "Bind Radeon 680M to VFIO in ASUS Ultimate mode";

    wantedBy = [
      "systemd-modules-load.service"
      "systemd-udevd-kernel.socket"
      "systemd-udevd-control.socket"
      "systemd-udevd-varlink.socket"
    ];

    requires = [ "vfio-gpu-mode-detect.service" ];
    after = [ "vfio-gpu-mode-detect.service" ];

    before = [
      "systemd-modules-load.service"
      "systemd-udevd-kernel.socket"
      "systemd-udevd-control.socket"
      "systemd-udevd-varlink.socket"
      "systemd-udevd.service"
      "systemd-udev-trigger.service"
    ];

    unitConfig.DefaultDependencies = false;

    path = with pkgs; [
      coreutils
      kmod
    ];

    serviceConfig.Type = "oneshot";

    script = ''
      set -eu

      WMI=/sys/devices/platform/asus-nb-wmi

      GPU_MUX_MODE=$(cat "$WMI/gpu_mux_mode")
      DGPU_DISABLE=$(cat "$WMI/dgpu_disable")

      echo "ASUS GPU mode: $GPU_MUX_MODE:$DGPU_DISABLE"

      case "$GPU_MUX_MODE:$DGPU_DISABLE" in
        1:1)
          echo "Integrated mode: leaving all GPU drivers unchanged."
          exit 0
          ;;
        0:1)
          echo "Hybrid mode: leaving all GPU drivers unchanged."
          exit 0
          ;;
        0:0)
          echo "Ultimate mode: preparing Radeon 680M for VFIO."
          ;;
        *)
          echo "ERROR: Unknown ASUS GPU mode."
          exit 1
          ;;
      esac

      DEVICES="0000:77:00.0 0000:77:00.1"

      # Validate every device before changing anything.
      for BDF in $DEVICES; do
        DEV="/sys/bus/pci/devices/$BDF"

        if [ ! -d "$DEV" ]; then
          echo "ERROR: PCI device $BDF does not exist."
          exit 1
        fi

        case "$BDF" in
          0000:77:00.0) EXPECTED_ID=0x1681 ;;
          0000:77:00.1) EXPECTED_ID=0x1640 ;;
        esac

        VENDOR=$(cat "$DEV/vendor")
        DEVICE=$(cat "$DEV/device")

        if [ "$VENDOR:$DEVICE" != "0x1002:$EXPECTED_ID" ]; then
          echo "ERROR: Unexpected PCI ID for $BDF: $VENDOR:$DEVICE"
          exit 1
        fi

        # Do not silently unbind an already-owned device.
        if [ -L "$DEV/driver" ]; then
          DRIVER=$(basename "$(readlink -f "$DEV/driver")")

          if [ "$DRIVER" != "vfio-pci" ]; then
            echo "ERROR: $BDF was already claimed by $DRIVER."
            exit 1
          fi
        fi

        # Require a dedicated IOMMU group.
        GROUP=$(readlink -f "$DEV/iommu_group")
        GROUP_COUNT=0

        for MEMBER in "$GROUP"/devices/*; do
          [ -e "$MEMBER" ] || continue
          GROUP_COUNT=$((GROUP_COUNT + 1))
        done

        if [ "$GROUP_COUNT" -ne 1 ]; then
          echo "ERROR: $BDF has $GROUP_COUNT devices in its IOMMU group."
          exit 1
        fi

        OVERRIDE=$(cat "$DEV/driver_override")

        case "$OVERRIDE" in
          "(null)"|"") ;;
          "vfio-pci") ;;
          *)
            echo "ERROR: Unexpected driver override for $BDF: $OVERRIDE"
            exit 1
            ;;
        esac
      done

      # Set the desired driver before loading it.
      for BDF in $DEVICES; do
        DEV="/sys/bus/pci/devices/$BDF"
        printf '%s\n' vfio-pci > "$DEV/driver_override"
      done

      echo "Loading VFIO modules..."

      modprobe vfio
      modprobe vfio_iommu_type1
      modprobe vfio_pci

      # Bind devices that have not already bound automatically.
      for BDF in $DEVICES; do
        DEV="/sys/bus/pci/devices/$BDF"

        if [ ! -L "$DEV/driver" ]; then
          printf '%s\n' "$BDF" > /sys/bus/pci/drivers/vfio-pci/bind
        fi
      done

      # Verify ownership.
      for BDF in $DEVICES; do
        DEV="/sys/bus/pci/devices/$BDF"

        if [ ! -L "$DEV/driver" ]; then
          echo "ERROR: $BDF has no driver after binding."
          exit 1
        fi

        DRIVER=$(basename "$(readlink -f "$DEV/driver")")

        if [ "$DRIVER" != "vfio-pci" ]; then
          echo "ERROR: $BDF is owned by $DRIVER, not vfio-pci."
          exit 1
        fi

        echo "$BDF successfully bound to $DRIVER."
      done

      echo "Radeon 680M and its audio function are ready for VFIO."
    '';
  };
}
