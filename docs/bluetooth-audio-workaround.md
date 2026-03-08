# Bluetooth Audio Device Pairing Workaround (BR/EDR Link Key Issue)

## Environment

| Component | Version/Detail |
|-----------|---------------|
| OS | NixOS (nixos-unstable) with Flakes |
| Kernel | Linux 6.18.x |
| Audio | PipeWire 1.4.x + WirePlumber |
| Bluetooth stack | BlueZ 5.84 |
| Bluetooth adapter | Intel AX series (integrated, USB ID `1D6B:0246`) |
| Desktop | Hyprland (Wayland) |
| Bluetooth manager | Blueman |
| Audio device | Shokz OpenFit 2+ by Shokz (MAC: `A0:0C:E2:15:0C:49`) |
| Other BT devices | HHKB-Hybrid_4 (keyboard, BLE), MX Ergo (mouse, BLE) |

### NixOS Bluetooth configuration

`modules/bluetooth.nix` (before fix):
```nix
{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
}
```

`modules/bluetooth.nix` (after fix):
```nix
{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;
}
```

`modules/audio.nix`:
```nix
{ ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
```

## Symptoms

- Audio output worked through the default device (monitor speakers via HDMI/DP)
- **Could not switch audio output to a Bluetooth device** (Shokz OpenFit 2+)
- In blueman-manager, the OpenFit repeatedly cycled between connect and disconnect
- The Shokz app on iPhone (multipoint connection) did not show this machine as connected
- Other Bluetooth devices (HHKB keyboard, MX Ergo mouse) worked fine

## Diagnosis

### Step 1: Check adapter and connected devices

```bash
bluetoothctl show       # Controller info - Intel AX, Powered: yes
bluetoothctl devices    # Only HHKB and MX Ergo listed, OpenFit not present
```

The OpenFit was not even registered as a known device despite repeated pairing attempts.

### Step 2: Check kernel logs

```bash
sudo dmesg | grep -i bluetooth
```

Output showed the Intel adapter initialized correctly, HHKB and MX Ergo connected as HID devices, but **no mention of OpenFit at all**.

### Step 3: Check BlueZ service logs

```bash
journalctl -u bluetooth --no-pager -n 50
```

This revealed the core errors:

```
bluetoothd: src/profile.c:ext_connect() Hands-Free Voice gateway failed connect to A0:0C:E2:15:0C:49: Connection reset by peer (104)
bluetoothd: profiles/audio/avdtp.c:avdtp_connect_cb() connect to A0:0C:E2:15:0C:49: Connection reset by peer (104)
```

Both HFP (Hands-Free) and AVDTP (A2DP audio transport) connections were being **rejected by the device** every ~30 seconds.

### Step 4: Attempt pairing

```bash
bluetoothctl scan on    # Found: A0:0C:E2:15:0C:49 OpenFit 2+ by Shokz
bluetoothctl pair A0:0C:E2:15:0C:49
# Result: Paired: yes, Pairing successful
bluetoothctl connect A0:0C:E2:15:0C:49
# Result: Failed to connect: org.bluez.Error.Failed br-connection-key-missing
```

The device **paired successfully over BLE** but the connection for audio profiles **failed** because the BR/EDR link key was missing.

### Step 5: Verify pairing state

```bash
bluetoothctl info A0:0C:E2:15:0C:49
```

After disconnecting, `Paired: no`, `Bonded: no` — the BLE pairing was not persisted as a bond, and no BR/EDR key existed.

## Background: BLE vs BR/EDR and CTKD

Bluetooth has two transport modes:

- **BR/EDR (Basic Rate / Enhanced Data Rate)**: Classic Bluetooth. Used for audio (A2DP, HFP), file transfer, etc.
- **BLE (Bluetooth Low Energy)**: Low-power protocol. Used for notifications, HID (keyboards/mice), fitness trackers, etc.

Many modern devices are **dual-mode**: they support both BLE and BR/EDR. The Shokz OpenFit 2+ advertises itself via BLE but uses BR/EDR for audio streaming (A2DP).

When a dual-mode device pairs over BLE, the Bluetooth specification provides **CTKD (Cross-Transport Key Derivation)** to derive the BR/EDR link key from the BLE key. However, as documented in [BlueZ issue #810](https://github.com/bluez/bluez/issues/810):

> When a device pairs over BLE with Secure Connections and P-256 keys, the derived BR/EDR keys require AES-CCM encryption with Secure Connections support on the BR/EDR side. If there is an encryption requirements mismatch, the derived keys cannot be used.

This means: **BLE pairing succeeds, but the derived BR/EDR key is rejected**, resulting in `br-connection-key-missing`.

## Investigation: What we tried and why it failed

### Attempt 1: blueman-applet interference

The first BLE pairing attempts via `bluetoothctl pair` failed with `AuthenticationCanceled`. Stopping `blueman-applet` (which was running in the background via Hyprland `exec-once`) resolved this — blueman was registering its own pairing agent that conflicted with `bluetoothctl`'s agent.

With blueman stopped, BLE pairing succeeded (`Paired: yes`), but the connection still failed with `br-connection-key-missing`.

### Attempt 2: ControllerMode=bredr

Since BLE pairing didn't produce BR/EDR keys, we tried forcing the adapter to BR/EDR-only mode:

```nix
# bluetooth.nix
ControllerMode = "bredr";
```

After `nixos-rebuild switch`, **all Bluetooth devices stopped working** — not just OpenFit, but HHKB and MX Ergo too. The journal showed:

```
bluetoothd: src/device.c:device_connect_le() ATT bt_io_connect(DE:C9:92:C0:CB:88): Connection refused (111)
```

This revealed that **HHKB and MX Ergo were connected via BLE**, not classic Bluetooth as assumed. `ControllerMode=bredr` disabled BLE entirely, breaking them. We immediately reverted to `dual` and rebuilt.

### Attempt 3: BR/EDR scan in dual mode

We tried `bluetoothctl scan bredr` in dual mode. The device was found, but `bluetoothctl pair` still paired over BLE — the scan filter only affects discovery, not the pairing transport.

### Attempt 4: ControllerMode=bredr with Experimental disabled

We suspected `Experimental=true` (which enables BLE features) was interfering with the bredr-only scan. After removing it and rebuilding, `bluetoothctl scan` still didn't find the device. However, `hcitool scan` (raw HCI inquiry, bypasses BlueZ D-Bus) found it immediately. This confirmed a BlueZ bug: **the discovery filter mechanism is broken in bredr-only mode**.

### Attempt 5: hcitool cc

Since `hcitool scan` worked, we tried `sudo hcitool cc <MAC>` to create a connection at the HCI level. The connection was created, but BlueZ's D-Bus layer didn't register the device — `bluetoothctl info` still showed "Device not available".

### Attempt 6: btmgmt pair (the breakthrough)

`btmgmt` is a lower-level Bluetooth management tool that communicates directly with the kernel's Bluetooth management API. Unlike `bluetoothctl` (which uses BlueZ's D-Bus API), `btmgmt` can specify the address type explicitly:

```bash
sudo btmgmt pair -c 3 -t 0 A0:0C:E2:15:0C:49
# -c 3: NoInputNoOutput capability
# -t 0: BR/EDR address type (forces BR/EDR pairing)
```

This **successfully generated a BR/EDR link key**. However, the output showed `store_hint 0`, meaning the device told BlueZ not to store the key persistently. After restarting the Bluetooth service, the key was lost and the device disappeared from BlueZ's database.

### Attempt 7: btmon + manual config (the solution)

Since `btmgmt` could generate the key but not persist it, we used `btmon` (Bluetooth monitor) to capture the key during pairing, then manually created the BlueZ device config file at `/var/lib/bluetooth/`. This is the approach that finally worked.

### Summary table

| Approach | Result |
|----------|--------|
| `bluetoothctl pair` (dual mode) | Pairs over BLE, `br-connection-key-missing` on connect |
| Stopping blueman-applet | BLE pairing succeeded, but BR/EDR key still missing |
| `ControllerMode=bredr` | HHKB/MX Ergo are BLE devices — they stopped working entirely |
| `bluetoothctl scan bredr` (dual mode) | Found the device but pairing still happened over BLE |
| `ControllerMode=bredr` + `bluetoothctl scan` | `bluetoothctl` scan broken in bredr-only mode (BlueZ bug) |
| `hcitool cc` (create HCI connection) | Connection created but BlueZ D-Bus didn't register the device |
| `btmgmt pair -t 0` | BR/EDR pairing succeeded, but key not persisted (`store_hint 0`) |
| **`btmgmt pair` + `btmon` + manual config** | **Success** — key captured and manually stored |

### Key discoveries

- **HHKB-Hybrid_4 and MX Ergo connect via BLE**, not BR/EDR classic. This was only discovered when `ControllerMode=bredr` broke them. Therefore `ControllerMode=bredr` is not a viable option.
- **`bluetoothctl scan` does not work in `ControllerMode=bredr`** (BlueZ bug), but `hcitool scan` (raw HCI inquiry) does. The `SetDiscoveryFilter` mechanism appears to be broken in bredr-only mode.
- **`btmgmt pair -c 3 -t 0 <MAC>`** successfully performs BR/EDR pairing and generates a link key, but `store_hint 0` means BlueZ doesn't persist it. The BlueZ daemon also doesn't register the device in its D-Bus database.
- **`btmon`** can capture the link key during `btmgmt pair`, and the key can be manually written to `/var/lib/bluetooth/` to create a persistent device entry that BlueZ recognizes.

## Solution

### Overview

Since BlueZ cannot properly pair dual-mode audio devices via its standard tools, we bypass it:

1. Use `btmgmt` (Bluetooth management tool) to perform BR/EDR pairing directly
2. Capture the link key with `btmon` (Bluetooth monitor)
3. Manually create the BlueZ device config file with the captured key
4. Restart BlueZ so it loads the new device

### Prerequisites

- `Experimental=true` and `FastConnectable=true` in BlueZ config (see NixOS config above)
- `btmon`, `hcitool`, `btmgmt` must be available (included with BlueZ on NixOS)

### Step-by-step

#### 1. Find the device via classic inquiry

Put the device in pairing mode, then:

```bash
hcitool scan
```

Expected output:
```
Scanning ...
    A0:0C:E2:15:0C:49    OpenFit 2+ by Shokz
```

**Important:** Do not use `bluetoothctl scan` — it may not find the device depending on the controller mode and discovery filter state.

#### 2. Capture the link key with btmon

Open **two terminals**.

**Terminal 1** — start Bluetooth monitor:
```bash
sudo btmon | tee /tmp/btmon.log
```

**Terminal 2** — perform BR/EDR pairing (device must be in pairing mode):
```bash
sudo btmgmt pair -c 3 -t 0 A0:0C:E2:15:0C:49
```

Options:
- `-c 3`: NoInputNoOutput IO capability (Just Works pairing)
- `-t 0`: BR/EDR address type (not BLE)

Expected output:
```
Pairing with A0:0C:E2:15:0C:49 (BR/EDR)
hci0 A0:0C:E2:15:0C:49 type BR/EDR connected eir_len 26
hci0 new_link_key A0:0C:E2:15:0C:49 type 0x04 pin_len 0 store_hint 0
Paired with A0:0C:E2:15:0C:49 (BR/EDR)
```

Stop `btmon` with Ctrl+C.

#### 3. Extract the link key

```bash
grep -i "link.key" /tmp/btmon.log
```

Output:
```
Link key[16]: <your_link_key>
```

Note: `store_hint 0` means BlueZ did not auto-store the key — this is why manual creation is necessary.

#### 4. Create the BlueZ device config file

```bash
sudo mkdir -p /var/lib/bluetooth/<ADAPTER_MAC>/<DEVICE_MAC>
```

Create the info file at `/var/lib/bluetooth/<ADAPTER_MAC>/<DEVICE_MAC>/info`:

```ini
[General]
Name=OpenFit 2+ by Shokz
Class=0x240404
SupportedTechnologies=BR/EDR;
Trusted=true
Blocked=false

[LinkKey]
Key=<YOUR_LINK_KEY>
Type=4
PINLength=0

[DeviceID]
Source=1
Vendor=0x02B0
Product=0x0000
Version=0x001F
```

Field explanations:
- `Key`: Link key from step 3, uppercase hex, no separators
- `Type=4`: Authenticated Combination Key from P-256
- `Class=0x240404`: Bluetooth device class (audio headset)
- `Vendor`, `Product`, `Version`: From `bluetoothctl info` output (`Modalias: bluetooth:v02B0p0000d001F`)

#### 5. Restart Bluetooth and connect

```bash
sudo systemctl restart bluetooth
bluetoothctl connect A0:0C:E2:15:0C:49
```

Expected output:
```
Attempting to connect to A0:0C:E2:15:0C:49
Device A0:0C:E2:15:0C:49 Connected: yes
BREDR A0:0C:E2:15:0C:49 Connected: yes
Connection successful
```

#### 6. Verify and set as default audio output

```bash
wpctl status
```

The device should appear as a PipeWire sink:
```
Audio
 ├─ Devices:
 │     147. OpenFit 2+ by Shokz                 [bluez5]
 │
 ├─ Sinks:
 │     146. OpenFit 2+ by Shokz                 [vol: 1.00]
```

Set it as the default output:
```bash
# Find the correct sink ID from wpctl status output (look for bluez_output node)
wpctl set-default <SINK_ID>
```

You can also switch audio output via `pavucontrol` (right-click the Waybar audio icon).

## Persistence

The link key stored in `/var/lib/bluetooth/` survives reboots. After a reboot, the device should reconnect automatically or via:

```bash
bluetoothctl connect A0:0C:E2:15:0C:49
```

If the device needs to be re-paired (e.g. after a factory reset), repeat the full procedure from step 1.

## Device-specific info

| Field | Value |
|-------|-------|
| Device | Shokz OpenFit 2+ |
| MAC | A0:0C:E2:15:0C:49 |
| Adapter | Intel AX (BC:D2:2C:C6:23:60) |
| BlueZ version | 5.84 |
| Profiles | A2DP Sink, HFP, AVRCP, Serial Port |

## Known limitations

- **Monitor audio switching** was also part of the original problem but was not addressed in this workaround. Monitor audio output switching (e.g. between HDMI/DP outputs) should work via `pavucontrol` or `wpctl set-default` once the correct sink IDs are identified with `wpctl status`.

## References

- [BlueZ issue #810: Connect to both LE and BR/EDR simultaneously](https://github.com/bluez/bluez/issues/810) — root cause of CTKD failure
- [Blueman issue #2203: Shokz OpenRun Pro device classification](https://github.com/blueman-project/blueman/issues/2203) — related Shokz + Linux issue
- [Arch Wiki: Bluetooth](https://wiki.archlinux.org/title/Bluetooth) — general Linux Bluetooth reference
