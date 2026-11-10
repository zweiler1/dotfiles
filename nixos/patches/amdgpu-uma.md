# Reverse-engineering and enabling AMD UMA carveout switching on ASUS TUF Gaming A16 FA617NS

## 1\. Executive summary

The objective was to make the integrated GPU's UMA framebuffer allocation switch automatically when changing GPU mode on an ASUS TUF Gaming A16 FA617NS.

The desired behavior:

| ASUS GPU mode | `dgpu_disable` | `gpu_mux_mode` | UMA allocation |
| --- | ---: | ---: | ---: |
| Integrated | 1 | 1 | 2 GB |
| Hybrid | 0 | 1 | 512 MB |
| Ultimate | 0 | 0 | 512 MB |

The firmware already supported changing the UMA allocation. The problem was that the installed Linux AMDGPU driver did not expose a usable UMA carveout interface for this particular firmware implementation.

The investigation uncovered three important layers:

1. **Firmware mechanism:** ASUS firmware exposes an AMD ACPI interface (`ATCS`) that can read and change the UMA allocation. The ACPI method ultimately reaches an SMI/SMM handler, which selects an AMD APCB token.
2. **Kernel support:** The laptop's AMD Integrated System Info table uses revision 2.2, whereas the relevant existing Linux parser expects revision 2.3. The parser therefore does not expose the normal UMA sysfs interface. A DMI-scoped kernel fallback was implemented using the firmware's ACPI GET/SET interface.
3. **ASUS userspace integration:** ASUS's `asus-shutdown` service applies GPU-mode changes later, during shutdown. A helper was integrated into that deferred operation so the UMA allocation is changed before ASUS applies the queued GPU-mode settings.

The resulting implementation works:

- The kernel exposes `carveout` and `carveout_options`.
- Writing index `1` selects 512 MiB.
- Writing index `2` selects 2 GiB.
- The selection survives reboot.
- ASUS GPU-mode switching automatically selects the appropriate UMA allocation during the deferred shutdown operation.

This was not achieved by simply changing a BIOS setting or setting an arbitrary kernel parameter. It required identifying the OEM firmware interface and connecting it to the Linux driver and ASUS's deferred GPU-mode workflow.

---

## 2\. Hardware and software baseline

### Hardware

| Component | Identified hardware |
| --- | --- |
| Laptop | ASUS TUF Gaming A16 FA617NS |
| Board | FA617NS |
| BIOS | FA617NS.419 |
| Integrated GPU | AMD Radeon 680M |
| iGPU architecture | Rembrandt, `gfx1035` |
| iGPU PCI address | `0000:77:00.0` |
| Discrete GPU | AMD Radeon Navi 33 / RX 7600-class |
| Operating system | NixOS 26.05 |
| Kernel | Custom Linux stable 7.3.1 build |

The iGPU's UMA allocation is the relevant setting. It controls how much system memory firmware reserves or makes available as the integrated GPU's dedicated framebuffer allocation.

### Software environment

The implementation used:

- NixOS 26.05.
- A custom kernel source tree at `~/env/nix/linux`.
- A separate working branch named `amdgpu-uma-debug`.
- ASUS `asusctl` / `asusd`.
- The `asus-shutdown` deferred shutdown service.
- `acpi_call` for firmware diagnostics.
- A NixOS package override to integrate the userspace helper and patch into `asusctl`.

The kernel was built through the existing NixOS kernel-package configuration, rather than by installing an independently compiled kernel manually.

The relevant system configuration eventually retained the kernel patch:

``` nix
boot = {
  kernelPackages = pkgs.linuxPackages_latest;

  kernelPatches = [
    {
      name = "amdgpu-uma";
      patch = ./patches/amdgpu-uma.patch;
    }
  ];
};
```

Temporary debugging parameters such as `drm.debug=0x02` were not needed for the final implementation. The kernel patch remained necessary.

---

## 3\. Initial investigation: identify what the system and firmware expose

The first important task was to establish exactly which hardware was involved and whether the UMA mechanism was already visible to Linux.

A useful inventory for this type of investigation is:

``` bash
uname -a
cat /etc/os-release

sudo dmidecode -t system
sudo dmidecode -t baseboard
sudo dmidecode -t bios

lspci -nnk
```

The important information is not just the GPU marketing name. It includes:

- The exact system and board identifiers.
- BIOS version.
- Integrated GPU PCI device.
- Discrete GPU PCI device.
- The AMDGPU driver bound to the iGPU.
- Kernel version.

This matters because a firmware-specific workaround must be scoped to the correct machine. Two laptops with the same Radeon 780M, for example, can have entirely different ACPI implementations and firmware interfaces.

### Inspecting AMDGPU's existing sysfs interface

The AMDGPU driver has a UMA carveout interface on supported hardware.

The relevant attributes are:

``` text
/sys/class/drm/cardN/device/uma/carveout
/sys/class/drm/cardN/device/uma/carveout_options
```

On this laptop, before the kernel changes, the existing driver path did not provide a usable interface for selecting the firmware's UMA modes.

That was an important distinction:

**The absence of the sysfs interface did not mean that the firmware lacked UMA switching. It meant Linux had not successfully established the supported UMA configuration for this firmware.**

The later investigation proved that the firmware could change the allocation independently of the Linux sysfs implementation.

### Why PCI and device paths matter

The final device was identified at:

``` text
0000:77:00.0
```

After the kernel patch, the sysfs path was:

``` text
/sys/class/drm/card1/device/uma/carveout
```

The path resolves to:

``` text
/sys/devices/pci0000:00/0000:00:08.1/0000:77:00.0/uma/carveout
```

This was verified with:

``` bash
readlink -f /sys/class/drm/card1/device/uma/carveout
```

The `card1` number is not a stable hardware identifier. The PCI address is a better way to identify the device.

---

## 4\. Linux kernel investigation: why the existing UMA parser did not work

A major finding was the firmware's AMD Integrated System Info table revision.

The laptop's firmware provided revision **2.2**.

The relevant existing Linux AMDGPU parser path expected revision **2.3**. The firmware's revision 2.2 data was therefore not accepted by that path, and the parser returned:

``` c
-ENODEV
```

This explains why the normal driver initialization did not produce the expected UMA carveout interface.

### Why this mattered

The tempting approach would have been to interpret the revision 2.2 table as though it were revision 2.3.

That would have been unsafe.

A different table revision can have different field meanings and layouts. Reserved bytes in one version must not be treated as valid fields from another version merely because the structure looks similar.

The correct solution was to preserve the existing parser for supported firmware revisions and add a separate fallback for this particular machine.

### Key lesson

When an AMD laptop does not expose the normal UMA interface, first determine:

1. Which Integrated System Info table revision the firmware provides.
2. Which revisions the running AMDGPU driver supports.
3. Whether the parser actually failed.
4. Whether another firmware interface can provide the current UMA setting.

Do not immediately assume that the firmware lacks support or that the BIOS needs an update.

---

## 5\. ACPI reverse engineering: finding the firmware GET and SET operations

The next step was to investigate the firmware's ACPI interface.

The relevant ACPI method was:

``` text
\_SB.PCI0.GP17.VGA.ATCS
```

This is an AMD ACPI interface exposed by the firmware.

Two functions were identified:

| Function | Purpose |
| --- | --- |
| `0x06` | GET current UMA carveout setting |
| `0x0A` | SET UMA carveout setting |

The ACPI methods internally dispatch through the firmware's `ATC6` and `ATCA` paths.

### The diagnostic tool: `acpi_call`

The `acpi_call` kernel module was used to execute ACPI methods directly through:

``` text
/proc/acpi/call
```

This bypassed the missing Linux UMA sysfs interface and allowed the firmware mechanism itself to be tested.

The GET operation used:

``` text
\_SB.PCI0.GP17.VGA.ATCS 0x06 0
```

The result distinguished the two observed UMA configurations:

| Firmware result | Memory allocation |
| --- | ---: |
| `0x200` | 512 MiB |
| `0x800` | 2048 MiB |

These values are hexadecimal megabytes:

- `0x200` = 512.
- `0x800` = 2048.

This established that the ACPI interface could read the actual firmware-selected allocation.

### Testing the SET operation

The SET call used the following payload for the two known settings:

**512 MiB:**

``` text
\_SB.PCI0.GP17.VGA.ATCS 0x0A {0x04, 0x00, 0x01, 0x00}
```

**2048 MiB:**

``` text
\_SB.PCI0.GP17.VGA.ATCS 0x0A {0x04, 0x00, 0x02, 0x00}
```

The important value is the firmware index:

| Index | Allocation |
| ---: | ---: |
| 1 | 512 MiB |
| 2 | 2048 MiB |

The firmware SET call returned a buffer containing the **previous GET result**. It did not necessarily return the newly selected setting.

This was an important experimental detail: a SET operation's return data must not be mistaken for confirmation that the requested setting was selected.

The correct verification sequence was:

1. Execute SET.
2. Execute a separate GET.
3. Check the GET result.
4. Reboot.
5. Execute GET again.

The setting persisted across reboot.

This established that the interface changes a firmware-persistent selection used on the next boot, rather than resizing the currently running GPU's framebuffer live.

---

## 6\. Going deeper: AML, SMI and SMM

Identifying the ACPI method was only part of the reverse engineering. The next task was to understand where the SET request went and what the firmware did with the supplied index.

### ACPI method dispatch

The `ATCS` method dispatches the GET and SET functions through its internal ACPI paths:

- GET through `ATC6`.
- SET through `ATCA`.

This showed that the interface was not simply changing a Linux driver parameter. It was communicating with the platform firmware.

### The SMI mechanism

The SET path ultimately reaches a System Management Interrupt mechanism.

The relevant I/O ports were identified as:

| Port | Function |
| --- | --- |
| `0xB2` | SMI command port |
| `0xB3` | SMI data port |

The command used was:

``` text
0xDE
```

The firmware's SMM handler interprets the submitted data and performs the platform-specific configuration operation.

SMM is important because it runs inside the firmware's System Management Mode, outside normal operating-system execution. Linux can request the operation through ACPI, but the firmware decides what the request means and which platform variables are changed.

### An important detail about the payload

The AML path examined did not pass all the apparent SET payload fields through to the SMM handler.

The SystemIO field involved in the operation was byte-wide. Consequently, the path delivered the UMA index byte, while the apparent type byte was not independently preserved through that path.

For the working operations, the effective type was therefore zero.

This prevented an incorrect assumption that the complete four-byte ACPI argument was necessarily interpreted by SMM exactly as supplied.

### Recovered SMM index mapping

The reverse-engineered SMM behavior indicated this mapping:

| Submitted index | SMM behavior |
| ---: | --- |
| 0 | No update |
| 1 | Select APCB token 2 |
| 2 | Select APCB token 3 |
| Other nonzero values except 2 | Select APCB token 2 |

The two observed settings therefore map to two AMD APCB tokens:

- Index 1 → token 2 → 512 MiB.
- Index 2 → token 3 → 2048 MiB.

This explains why the indexes are firmware-defined identifiers, not arbitrary Linux enumeration positions.

---

## 7\. BIOS and UEFI image inspection

The firmware binary was also inspected to identify relevant AMD firmware components and configuration references.

One useful finding was a string in the AMD DXE component:

``` text
AmdNbioGfxRMBDxe
```

The component contained the string:

``` text
Get APCB_TOKEN_UID_UMAMODE
```

The relevant APCB token UID identified during the investigation was:

``` text
0x1FB35295
```

This provided an additional connection between the observed SMM behavior and AMD's APCB configuration mechanism.

APCB is the AMD platform configuration block mechanism used by firmware to store and retrieve platform configuration tokens.

### What this established

The observed UMA allocation was not simply a Linux-only variable.

The firmware was selecting a persistent AMD platform configuration value through its own SMM/APCB path.

The evidence connected:

1. The ACPI `ATCS` interface.
2. The SMI operation.
3. The SMM callback.
4. The APCB token selection.
5. The resulting UMA allocation reported by the subsequent GET operation.

### What it did not establish: 4 GB UMA

There was an additional research lead involving other APCB token values and firmware references.

AMD documentation and examples can show a 4 GB option using a different index on other platforms. The presence of references to `Get APCB_TOKEN_UID_UMAMODE` also suggested that additional firmware token values might exist.

However, **we did not establish a working 4 GB option on this ASUS laptop**.

The discovered ATCS/SMI path was experimentally verified for:

- Index 1: 512 MiB.
- Index 2: 2 GiB.

There was no confirmed 4 GB allocation through the discovered interface.

The existence of an index 3 or a token 6 on another AMD platform is not evidence that this machine supports it. Discovering another valid allocation would require further firmware investigation and independent GET verification.

---

## 8\. Implementing the kernel fallback

Once the firmware mechanism was understood, the next task was to make it available through the standard AMDGPU sysfs interface.

The implementation was maintained in:

``` text
patches/amdgpu-uma.patch
```

The corresponding kernel source was developed in the local Linux tree on:

``` text
amdgpu-uma-debug
```

### Main kernel changes

The patch made several coordinated changes.

#### 8.1 ACPI GET helper

An ACPI helper was added to the AMDGPU ACPI code:

``` text
drivers/gpu/drm/amd/amdgpu/amdgpu_acpi.c
```

A corresponding declaration was added to the relevant header.

The helper invokes the firmware GET operation and obtains the current UMA index/allocation.

This is important because the kernel must not assume that its default value matches the actual persistent firmware selection.

#### 8.2 Extend the UMA option representation

The UMA carveout option structure was extended to represent the firmware index and type.

The driver must retain the actual firmware-defined index. It cannot simply assume that the first array entry is index 0 and the second is index 1.

That distinction is particularly important here because the actual firmware indexes are 1 and 2.

#### 8.3 Add a firmware-specific fallback

The fallback is restricted to the target laptop using DMI identification:

``` text
ASUS TUF FA617NS
BIOS FA617NS.419
```

The fallback is used when the normal parser fails with:

``` c
-ENODEV
```

The existing parser path remains intact for systems with supported Integrated System Info data.

This is a critical design choice: the workaround does not globally replace AMDGPU's existing UMA parser or reinterpret unsupported firmware table revisions.

#### 8.4 Preserve real firmware indexes

The sysfs option display and write paths were updated so that the value written by userspace is the actual firmware index.

This means:

``` bash
echo 1 | sudo tee /sys/class/drm/card1/device/uma/carveout
```

selects the real firmware index 1, rather than merely selecting the first element of a kernel array.

Likewise, writing `2` selects the real firmware index 2.

#### 8.5 Initialize the current setting using GET

The driver obtains the current firmware setting through the ACPI GET helper.

This ensures that the sysfs `carveout` value reflects the actual persisted firmware configuration after boot.

#### 8.6 Synchronization and cleanup

The patch also accounts for the initialization state of the update lock through an `update_lock_initialized` flag.

That prevents cleanup code from attempting to destroy a lock that was never successfully initialized.

This is important for a fallback initialization path, where failures can occur partway through setup.

### Resulting sysfs interface

After booting the patched kernel, the following attributes were available:

``` text
/sys/class/drm/card1/device/uma/carveout
/sys/class/drm/card1/device/uma/carveout_options
```

Reading the options showed:

``` text
1: Productivity (512 MB)
2: Gaming (2 GB)
```

Reading the active selection showed:

``` text
1
```

After writing index 2:

``` bash
echo 2 | sudo tee /sys/class/drm/card1/device/uma/carveout
```

the current selection became:

``` text
2
```

The actual firmware GET operation independently confirmed the 2048 MiB setting.

### Kernel test result

The kernel implementation was tested on the actual laptop.

Both settings worked, persisted over reboot and were reflected by the firmware GET operation.

This confirmed that the kernel patch was not merely changing the displayed sysfs value: it was changing the actual firmware configuration.

---

## 9\. Integrating with ASUS Armoury and asusctl

With the kernel interface working, the remaining requirement was automatic switching when the ASUS GPU mode changes.

The important finding was that ASUS does not necessarily apply the GPU-mode setting immediately.

The deferred settings are held by `asusd` and applied by:

``` text
asus-shutdown
```

during the shutdown/reboot sequence.

This was the correct integration point for UMA switching.

### Discovering the queued GPU values

The pending ASUS Armoury settings were examined using:

``` bash
env IS_SERVICE=0 asus-shutdown
```

This invokes the program in dry-run mode, printing the pending deferred actions rather than running the actual shutdown service.

The relevant queue entries looked like:

``` text
dgpu_disable => 0
gpu_mux_mode => 1
```

The Armoury settings could also be inspected with:

``` bash
asusctl armoury list
```

The observed mapping was:

| Mode | `dgpu_disable` | `gpu_mux_mode` |
| --- | ---: | ---: |
| Integrated | 1 | 1 |
| Hybrid | 0 | 1 |
| Ultimate | 0 | 0 |

This was critical. It meant the helper did not need to inspect the graphical ASUS application, query an additional service, or guess the selected mode.

The already queued ASUS settings contained the information needed to choose the UMA allocation.

### Why the operation belongs in `asus-shutdown`

The ASUS service sequence is effectively:

1. ASUS Armoury settings are queued.
2. `asus-shutdown` fetches the pending settings.
3. It performs GPU-idle and firmware-write safety preparation.
4. It applies the queued GPU firmware settings.

The UMA selection must happen between the safety preparation and the actual application of the queued GPU-mode settings.

That way, both settings are prepared for the same next boot.

---

## 10\. The userspace UMA helper

A helper named:

``` text
amdgpu-uma-mode
```

was implemented as a Nix-generated shell script using:

``` nix
pkgs.writeShellScriptBin
```

It accepts two arguments:

``` text
amdgpu-uma-mode <dgpu_disable> <gpu_mux_mode>
```

Its mapping is:

``` bash
case "$1:$2" in
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
        # Leave UMA unchanged
        ;;
esac
```

The helper then:

1. Finds the UMA `carveout` sysfs attribute.
2. Checks that exactly one candidate was found.
3. Reads the current index.
4. Avoids writing if the requested index is already selected.
5. Writes the requested index when necessary.
6. Logs the result through `logger`.

The helper uses:

``` text
/sys/class/drm/card*/device/uma/carveout
```

rather than permanently assuming `card1`.

It requires exactly one matching UMA attribute to avoid silently modifying the wrong device or selecting an ambiguous device.

### An important interface correction

The first helper implementation attempted to run `asus-shutdown` itself and parse the dry-run output.

That approach became unnecessary once the Rust code was modified to pass the queued settings directly to the helper.

The final helper uses:

``` bash
DGPU_DISABLE="${1:-}"
GPU_MUX_MODE="${2:-}"
```

It validates both arguments and leaves UMA unchanged when they are missing or invalid.

This is better because it avoids launching a second instance of `asus-shutdown`, parsing log text, and potentially reading a different queue state.

The source of truth is the `queued` data already held by the running Rust process.

---

## 11\. Integrating the helper into the asusctl package

Rather than installing a separate manually managed script, the helper was integrated into the custom NixOS `asusctl` package override.

The relevant package expression was based on:

``` nix
pkgs.asusctl.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    ../../patches/asus-shutdown-uma.patch
  ];

  postInstall = (old.postInstall or "") + ''
    install -Dm755 ${amdgpuUmaMode}/bin/amdgpu-uma-mode "$out/bin/amdgpu-uma-mode"
  '';
})
```

The package override retained the original asusctl derivation and extended it with:

- The custom Rust patch.
- The installed `amdgpu-uma-mode` helper.

### Important Nix packaging failure: changing `pname`

An earlier attempt changed:

``` nix
pname = "asusctl-uma";
```

This caused the build to fail during `patchPhase` with:

``` text
substituteInPlace called without any files to operate on
```

The failure was unrelated to the Rust patch.

The inherited Nixpkgs package logic contained a `substituteInPlace` step whose file path depended on the original `asusctl` naming convention and vendored source path.

Changing `pname` broke the inherited path assumption, resulting in an empty file expansion.

**Fix:** remove the `pname` override and keep the inherited package name.

There is no need to change the package name merely because patches and installation steps have been added.

---

## 12\. The Rust patch: exact integration point

The Rust patch was added to:

``` text
asus-shutdown/src/main.rs
```

Inside:

``` rust
async fn apply_shutdown_settings()
```

The helper runs after:

``` rust
prepare_nvidia_for_gpu_firmware_writes().await;
```

and before:

``` rust
info!("[phase 6/6] Proceeding with applying deferred GPU settings");
```

The Rust code extracts the two relevant settings from the already fetched `queued` list:

``` rust
let dgpu_disable = queued
    .iter()
    .find(|action| action.name.as_str() == "dgpu_disable")
    .map(|action| action.value);

let gpu_mux_mode = queued
    .iter()
    .find(|action| action.name.as_str() == "gpu_mux_mode")
    .map(|action| action.value);
```

It only calls the helper when both settings are available:

``` rust
match (dgpu_disable, gpu_mux_mode) {
    (Some(dgpu_disable), Some(gpu_mux_mode)) => {
        // Run the helper with both queued values.
    }
    _ => {
        // Leave UMA unchanged.
    }
}
```

The helper is launched using:

``` rust
std::process::Command::new(
    "/run/current-system/sw/bin/amdgpu-uma-mode"
)
.arg(dgpu_disable.to_string())
.arg(gpu_mux_mode.to_string())
.status()
```

The result is logged:

- Successful execution: UMA update completed.
- Nonzero exit: helper failure warning.
- Execution error: helper launch warning.
- Missing queued mode: UMA remains unchanged.

The use of the absolute executable path avoids depending on the service's runtime `PATH`.

### Why the ordering matters

The UMA firmware operation happens after the existing dGPU safety preparation and before ASUS applies the queued GPU-mode settings.

The complete sequence is therefore:

1. Fetch pending GPU settings.
2. Wait for the dGPU to become idle.
3. Wait for logind to exit as part of the actual shutdown process.
4. Prepare the NVIDIA safety gates.
5. Set the UMA carveout based on the queued GPU mode.
6. Apply the deferred ASUS GPU settings.

This keeps the UMA selection associated with the same queued mode change.

---

## 13\. Systemd sandboxing: why the helper needed explicit write access

The `asus-shutdown.service` unit is sandboxed.

Important settings included:

``` ini
ProtectSystem=strict
ReadOnlyPaths=/
```

The helper runs as a child of this service. Consequently, even though the sysfs attribute is writable for a privileged process outside the service, the service's filesystem sandbox can prevent writes.

The solution was a narrow systemd write exception:

``` nix
systemd.services.asus-shutdown.serviceConfig.ReadWritePaths = [
  "/sys/devices/pci0000:00/0000:00:08.1/0000:77:00.0/uma/carveout"
];
```

This grants the service write access to the specific sysfs attribute without making the whole sysfs tree writable.

The actual path was resolved using `readlink -f`, rather than guessed.

This is an important general lesson: **a helper can work perfectly when run manually and still fail when launched by a sandboxed systemd unit.** Always inspect the service's effective sandbox settings when a sysfs write works interactively but fails during service execution.

---

## 14\. A second runtime failure: SIGTERM and the ASUS shutdown service

After the package built successfully, the NixOS activation failed when starting `asus-shutdown.service`.

The error was:

``` text
Failed to start asus-shutdown.service
```

The journal contained:

``` text
Received SIGTERM
Deferring exit until deferred shutdown apply reaches a safe completion point
```

followed by:

``` text
State 'stop-sigterm' timed out.
Skipping SIGKILL.
```

The process remained alive even after systemd marked the service failed.

### The actual root cause

The original signal handler in `asus-shutdown/src/main.rs` looked like:

``` rust
_ = sigterm.recv() => {
    warn!("Received SIGTERM");
    warn!("Deferring exit until deferred shutdown apply reaches a safe completion point");
}
```

It logged SIGTERM but did not terminate the event loop.

The process kept waiting for a logind `PrepareForShutdown` event.

That is a valid event to wait for during normal operation, but it does not necessarily arrive when systemd stops the service for an ordinary service restart.

The service unit contained:

``` ini
PartOf=asusd.service
Requires=asusd.service
```

Consequently, restarting `asusd` during a NixOS configuration switch also stops `asus-shutdown`.

The stop operation sends SIGTERM. The process does not exit. The service also had:

``` ini
TimeoutStopSec=45
SendSIGKILL=no
```

This combination caused the 45-second timeout and allowed the remaining process to survive.

### Fix

The SIGTERM branch was changed to exit the event loop cleanly:

``` rust
_ = sigterm.recv() => {
    warn!("Received SIGTERM, exiting cleanly");
    break;
}
```

This preserves the actual shutdown-event path.

A real shutdown still triggers `PrepareForShutdown(true)`, which runs `apply_shutdown_settings()`, applies the UMA helper and queued ASUS settings, releases the inhibitor, and exits.

An ordinary service stop or restart now terminates cleanly rather than waiting indefinitely for an unrelated shutdown event.

This change was added to the same Rust patch.

The resulting patch has two independent modifications:

1. A SIGTERM handler correction.
2. The UMA helper invocation inside `apply_shutdown_settings()`.

### Additional diagnostics used

The failure was isolated with:

``` bash
sudo journalctl -b -u asus-shutdown.service --no-pager
```

``` bash
sudo systemctl cat asus-shutdown.service
```

``` bash
sudo systemctl show asus-shutdown.service \
  -p MainPID \
  -p TimeoutStopUSec \
  -p TimeoutAbortUSec \
  -p KillSignal \
  -p FinalKillSignal \
  -p SendSIGKILL \
  -p KillMode \
  -p PartOf
```

``` bash
pgrep -af asus-shutdown
```

These confirmed that the problem was the signal-handling logic, not an ACPI failure, a sysfs failure, or the UMA mapping itself.

The stale process from the failed activation also had to be terminated and the service's failed state reset before retrying.

---

## 15\. Final tool inventory

The following is the practical toolchain used or directly involved in this investigation, grouped by job.

| Tool | Job | What it established |
| --- | --- | --- |
| `lspci` | PCI hardware inventory | Identified GPU devices and PCI topology |
| `dmidecode` | DMI/BIOS inventory | Identified laptop, board and BIOS version for machine-specific scoping |
| `uname` | Kernel identification | Verified which kernel version was running |
| Linux AMDGPU source | Kernel implementation investigation | Identified the supported table parser and UMA sysfs implementation |
| `acpi_call` | Direct ACPI method invocation | Tested ATCS GET and SET without relying on the missing sysfs interface |
| `/proc/acpi/call` | Interface for `acpi_call` | Executed the firmware methods |
| ACPI/AML inspection | Firmware method tracing | Connected ATCS to the underlying ATC6/ATCA and SMI paths |
| BIOS/UEFI image inspection | Firmware component analysis | Identified AMD DXE/APCB references and the UMA token UID |
| `readlink -f` | Sysfs path resolution | Identified the actual PCI-backed UMA attribute path |
| `cat` | Sysfs inspection | Read current UMA index and supported options |
| `tee` / sysfs write | UMA selection testing | Submitted firmware indexes 1 and 2 |
| `asusctl armoury list` | ASUS settings inspection | Identified Armoury GPU attributes |
| `IS_SERVICE=0 asus-shutdown` | Deferred queue inspection | Revealed the queued `dgpu_disable` and `gpu_mux_mode` values |
| Rust source inspection | ASUS shutdown integration | Identified the correct insertion point and signal-handling issue |
| Nix `overrideAttrs` | ASUS package customization | Integrated the Rust patch and shell helper into the package |
| `nixos-rebuild` | System build and activation | Built and activated the custom kernel and ASUS package |
| `nix log` | Derivation diagnostics | Identified patch and packaging failures |
| `systemctl cat/show` | systemd investigation | Revealed service dependencies, timeout, SIGKILL and sandbox settings |
| `journalctl` | Runtime diagnostics | Confirmed the SIGTERM failure |
| `pgrep` | Process inspection | Found the process left running after failed activation |
| `logger` | Helper logging | Recorded UMA update results in the system journal |

### BIOS inspection tool attribution

The findings from the BIOS/UEFI analysis are preserved, including the DXE component and APCB token references. However, the exact names and versions of every firmware extraction or binary inspection utility used in that phase are not retained in the available project notes.

For a reproducible investigation on another machine, the usual tool categories are:

- BIOS image acquisition and extraction.
- UEFI firmware volume and PE/COFF module inspection.
- String and symbol searching.
- Disassembly/decompilation of relevant firmware code.
- ACPI table dumping and AML disassembly.

Tools commonly used for those tasks include UEFITool/UEFIExtract, `strings`, Ghidra, `acpidump`, and `iasl`. These are useful candidates for reproducing the work; they should not all be assumed to have been used in this particular investigation.

---

## 16\. Final root-cause summary

There were several independent issues. Keeping them separate made the investigation much faster.

| Problem | Root cause | Resolution |
| --- | --- | --- |
| No usable UMA sysfs interface | AMD Integrated System Info revision 2.2 was not accepted by the relevant existing parser path expecting revision 2.3 | Add a DMI-scoped ACPI fallback |
| Unknown firmware indexes | Firmware used its own index mapping | Reverse-engineer ATCS/SMM mapping; use 1 and 2 |
| Need to persist UMA setting | Firmware applies selection on next boot | Use ACPI SET and verify independently with GET after reboot |
| UMA selection must follow GPU mode | ASUS stores GPU-mode changes in a deferred queue | Read `dgpu_disable` and `gpu_mux_mode` from `asus-shutdown` |
| Helper originally queried ASUS again | Unnecessary second invocation and text parsing | Pass the already queued values directly as arguments |
| Rust patch initially failed | Patch context did not match exact source, including blank lines | Re-anchor and correct the hunk context |
| Nix package failed in `substituteInPlace` | Overriding `pname` broke a hard-coded inherited vendor path | Remove the `pname` override |
| Service could not write sysfs | systemd `ProtectSystem=strict` and `ReadOnlyPaths=/` sandbox | Add a narrow `ReadWritePaths` exception |
| NixOS activation timed out | SIGTERM handler logged the signal but did not exit; service was restarted as part of `asusd` lifecycle | Change handler to `break` |
| Process remained alive after timeout | `SendSIGKILL=no` and a nonterminating signal handler | Fix the handler and clean up the stale process |

---

## 17\. Final working architecture

The completed setup has three layers.

### Layer 1: Kernel

The custom AMDGPU kernel patch exposes:

``` text
/sys/class/drm/card1/device/uma/carveout
/sys/class/drm/card1/device/uma/carveout_options
```

It handles the firmware-specific ACPI fallback and translates sysfs writes into the firmware-defined UMA indexes.

### Layer 2: ASUS userspace helper

The Nix-installed helper:

``` text
amdgpu-uma-mode
```

accepts the queued ASUS GPU settings and translates them into the appropriate UMA index.

### Layer 3: ASUS deferred shutdown

The patched `asus-shutdown` program invokes the helper before applying the queued GPU-mode settings.

The systemd service is explicitly permitted to write the one UMA sysfs attribute.

The SIGTERM handler exits cleanly during service restarts, while actual shutdown events continue to execute the deferred GPU-mode operation.

### Final behavior

``` text
ASUS Armoury GPU mode changed
            |
            v
      asusd queues settings
            |
            v
      shutdown/reboot
            |
            v
      asus-shutdown
            |
            v
      Fetch queued settings
            |
            v
      dGPU / firmware safety preparation
            |
            v
      amdgpu-uma-mode
            |
            +---- Integrated (1:1) --> UMA index 2
            |
            +---- Hybrid (0:1) -----> UMA index 1
            |
            +---- Ultimate (0:0) ---> UMA index 1
            |
            v
      Apply ASUS deferred GPU settings
            |
            v
          Reboot
            |
            v
      Firmware uses selected UMA allocation
```

The resulting configuration provides:

- Integrated mode: 2 GiB UMA.
- Hybrid mode: 512 MiB UMA.
- Ultimate mode: 512 MiB UMA.

The user confirmed that the complete automatic switching workflow works as intended.

---

## 18\. How to investigate the same problem on another AMD laptop

This is the most reusable part of the work.

A different laptop, such as a Dell with a Ryzen APU and Radeon 780M, should be investigated from scratch. The architecture may be similar, but the OEM firmware implementation must not be assumed to be the same.

In particular, do not copy the ASUS `ATCS` path, SMI command, APCB token, DMI match, or firmware index mapping to another vendor.

### Phase A — Establish the hardware baseline

Collect:

``` bash
uname -a
lspci -nnk
sudo dmidecode -t system
sudo dmidecode -t baseboard
sudo dmidecode -t bios
```

Record:

- Laptop model and board.
- BIOS version.
- APU generation and GPU architecture.
- iGPU PCI address.
- dGPU PCI address, if present.
- Kernel version.
- Whether the normal UMA sysfs interface exists.

Do not use only the GPU marketing name as an identifier.

### Phase B — Inspect existing Linux support first

Before reverse-engineering the firmware, inspect the running kernel and AMDGPU source.

Questions to answer:

1. Does the kernel already expose `uma/carveout`?
2. Is `carveout_options` populated?
3. Which firmware table supplies the options?
4. Which Integrated System Info revision does the BIOS provide?
5. Does the parser reject that revision?
6. Is there already an upstream or vendor-specific fallback?

If normal Linux support works, use it. There is no reason to reimplement a working firmware interface.

If it fails, establish whether the cause is an unsupported table revision, missing table data, or an entirely different firmware architecture.

### Phase C — Investigate ACPI before writing firmware values

Dump and inspect ACPI tables.

Typical tools include:

``` text
acpidump
iasl
```

Search for:

- AMD GPU device scopes.
- `_DSM` methods.
- AMD ATCS interfaces.
- OEM WMI interfaces.
- Methods that read or write UMA-related fields.
- SystemIO regions.
- SMI command and data ports.

On the ASUS system, the key method was:

``` text
\_SB.PCI0.GP17.VGA.ATCS
```

A Dell may expose something entirely different.

Start with read-only firmware operations and determine what values represent the current setting.

### Phase D — Establish GET semantics before SET semantics

Find a read operation that reports the current UMA allocation.

Verify it under different BIOS or OEM utility settings, if possible.

Only after GET is understood should you investigate SET.

For each suspected setting:

1. Record the current GET response.
2. Submit a known SET operation.
3. Perform GET again.
4. Check the reported amount.
5. Reboot.
6. Perform GET again.

Do not assume that a SET method's returned buffer is the newly selected value.

On the ASUS, the SET method returned the old GET buffer, so a separate GET was essential.

### Phase E — Trace the firmware implementation

If ACPI dispatches into SMI/SMM, determine:

- Which ports are used.
- Which command is sent.
- Which data bytes reach SMM.
- Whether AML truncates or transforms the arguments.
- Which SMM handler consumes them.
- Whether the handler changes an APCB token, NVRAM variable, or another persistent value.

Inspecting the BIOS/UEFI image can reveal useful leads:

- DXE drivers.
- UMA mode strings.
- APCB token UIDs.
- Setup variables.
- SMM-related firmware components.

The important point is to connect observed behavior to code paths rather than assume a string found in the BIOS proves a feature is enabled.

### Phase F — Determine real supported allocations

Do not assume that the index values are sequential or identical across platforms.

Build an empirical table:

| Index | GET result | Allocation | Survives reboot? |
| ---: | --- | ---: | --- |
| ? | Observed response | ? | Yes/No |

Only publish or expose modes that have been independently verified.

A generic AMD example showing a 4 GB index does not establish that a specific Dell or ASUS BIOS supports 4 GB.

### Phase G — Implement kernel support using the safest available layer

Prefer the existing AMDGPU sysfs interface.

If an existing parser is insufficient:

1. Preserve the working generic parser.
2. Add a platform-specific fallback only where necessary.
3. Scope it with the appropriate DMI or firmware identification.
4. Use a firmware GET method to initialize the actual current setting.
5. Preserve firmware-defined indexes.
6. Make the sysfs display and store methods agree.
7. Handle partial initialization and cleanup correctly.
8. Test both the sysfs readback and firmware GET result.

Do not parse a newer table layout from an older revision just because the structures appear similar.

### Phase H — Integrate with the OEM's GPU-mode switch

Find where the OEM stores and applies GPU-mode changes.

Possible mechanisms include:

- A D-Bus daemon.
- WMI interfaces.
- ACPI methods.
- An OEM userspace utility.
- A deferred shutdown/reboot service.

For the ASUS implementation, the useful source was `asus-shutdown`, and the queued values were available before the firmware settings were applied.

For a Dell, the relevant application or daemon may be completely different.

The desired integration sequence is:

1. Read the intended new GPU mode.
2. Determine the matching UMA allocation.
3. Set the UMA selection before the GPU-mode firmware change.
4. Apply the queued GPU-mode settings.
5. Verify the new setting after reboot.

Avoid parsing human-readable output if the source process already has structured values available.

### Phase I — Test lifecycle and security

A working sysfs write from an interactive root shell does not prove it will work from a service.

Inspect:

``` bash
systemctl cat <service>
systemctl show <service>
journalctl -b -u <service>
```

Check:

- `ProtectSystem`.
- `ReadOnlyPaths`.
- `ReadWritePaths`.
- `PrivateMounts`.
- `PartOf`.
- `Requires`.
- `TimeoutStopSec`.
- `SendSIGKILL`.
- Signal-handling behavior.

If the service is restarted during ordinary system activation, its SIGTERM path must not accidentally wait for a real machine shutdown.

Grant the smallest possible sysfs write exception.

### Phase J — Validate the complete behavior

Test both direct UMA switching and automatic OEM mode integration.

A good test matrix is:

| Test | Expected result |
| --- | --- |
| Write 512 MiB index | GET reports 512 MiB |
| Reboot after 512 MiB selection | GET still reports 512 MiB |
| Write 2 GiB index | GET reports 2 GiB |
| Reboot after 2 GiB selection | GET still reports 2 GiB |
| Select Integrated mode | Helper selects 2 GiB |
| Select Hybrid mode | Helper selects 512 MiB |
| Select Ultimate mode | Helper selects 512 MiB |
| Restart the OEM daemon/service | Shutdown helper exits cleanly |
| Actual reboot/shutdown | Deferred settings are applied in the intended order |

Keep the firmware GET method as an independent verification mechanism throughout testing.

---

## 19\. Most important lessons for future reverse engineering

The discoveries that saved the most time were these:

1. **An absent Linux sysfs interface does not establish absent firmware capability.** Check the firmware interface directly.
2. **The firmware table revision matters.** A parser rejecting an older revision is not proof that the hardware cannot perform the operation.
3. **ACPI GET is especially valuable.** It provides an independent readback mechanism and prevents confusing a requested value with an applied value.
4. **Trace the call chain all the way down.** ACPI, AML, SystemIO, SMI, SMM and APCB were all part of this one apparently simple UMA setting.
5. **Firmware indexes are not necessarily zero-based.** The ASUS system uses 1 and 2, and those values must remain intact through the kernel sysfs interface.
6. **Read the OEM daemon's source code.** The ASUS GPU-mode change was deferred, and that fact determined the correct place to integrate UMA switching.
7. **Pass structured values rather than parsing another process's output.** The Rust service already held the queued GPU-mode values.
8. **Inspect systemd sandboxing.** A correct sysfs helper can still fail because the service is not allowed to write the attribute.
9. **Inspect signal handling during service restarts.** A shutdown daemon must distinguish an actual logind shutdown event from an ordinary systemd stop.
10. **Use narrow, hardware-specific fallbacks.** Never turn a platform-specific reverse-engineered firmware interface into a generic AMDGPU assumption.

## Final result

The completed solution uses the ASUS firmware's existing UMA selection mechanism, exposes it through a custom AMDGPU kernel fallback, and connects that interface to ASUS's deferred GPU-mode switching.

The core firmware behavior was experimentally demonstrated, the kernel sysfs interface was implemented and tested, and the automatic ASUS integration was completed.

The resulting system automatically selects 2 GiB UMA in Integrated mode and 512 MiB in Hybrid and Ultimate modes, with the setting persisted by firmware across reboot.
