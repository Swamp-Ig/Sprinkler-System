# 6-Zone WiFi Sprinkler Controller

A custom PCB for controlling up to six 24 VAC irrigation solenoid valves via WiFi, using an ESP32 and ESPHome with native Home Assistant integration.

## Features

- **6 independent zones** — each zone switches a 24 VAC solenoid valve via an Omron G5LE-1 relay
- **WiFi control** — ESP32-WROOM-32U with external U.FL antenna connector
- **Home Assistant integration** — ESPHome firmware; zones appear as switch entities
- **Onboard power supply** — HLK-PM01 AC-DC module (mains → 5 V); AMS1117-3.3 regulator (5 V → 3.3 V for ESP32)
- **Relay isolation** — ULN2803A Darlington array isolates ESP32 GPIOs from relay coil drive current
- **Protected design** — varistors on each zone output and across the mains input and transformer primary (RV1/RV2), time-delay fuses on the mains and 24 VAC supplies, per-zone RC snubbers, and an optocoupler-isolated 24 VAC rail sense

## ⚠️ Safety

> **This board carries mains voltage (Line and Neutral) on the PCB.**  
> The HLK-PM01 module is connected directly to mains. The 24 VAC solenoid rail is transformer-isolated but still carries AC voltage.

- Do **not** touch or probe the board while it is powered.
- The enclosure **must** be non-conductive and fully closed before applying mains power.
- All mains wiring must comply with local electrical codes. Use appropriately rated cable and terminals.
- The external transformer must be safety-rated (UL, CE, or equivalent) for your locale.
- Replace fuses only with the specified ratings — see the BOM below.

### Enclosure

This board must be installed in a suitable enclosure. Since it is likely to be installed outdoors near irrigation equipment:

- **IP65 minimum** — dust-tight and protected against water jets. IP66 or better if there is any chance of direct spray or hosing down.
- Use a **non-conductive (plastic) enclosure** — metal enclosures require additional insulation between the mains terminals and the enclosure wall.
- All cable entry points must be sealed with appropriate **cable glands** rated for the enclosure IP class.
- Mount the enclosure **vertically** with cable entries facing down to prevent water pooling at the glands.

### Conformal Coating

Even inside a sealed enclosure, condensation can form on the PCB during temperature cycling. Apply conformal coating after final assembly and testing:

- **Mask before coating**: screw terminals (J2–J3), pluggable terminal connectors (J1, J20–J25; KF2EDG-style), fuse holders, the ESP32 U.FL connector, and the USB-to-UART header (J5) so they remain accessible.
- Apply 2–3 thin coats of acrylic or silicone conformal coating to both sides of the PCB.
- Allow to fully cure before installing in the enclosure.

## How It Works

The controller has three linked paths: logic power, 24 VAC valve power, and relay control.

### Logic power path
Mains (L + N) -> Fuse (F1) -> HLK-PM01 -> 5 V -> AMS1117-3.3 -> 3.3 V -> ESP32 + logic

### 24V Transformer
Mains (L + N) -> Fuse (F1) -> G3MB-202P SSR (K1) -> Transformer Out (J2)

### Valve power path
Transformer In (J3) -> Fuse (F2) -> zone switching relays (K20–25) -> solenoids

### Control path
ESP32 GPIO16 controls K1 (24 VAC rail enable)
ESP32 GPIO17/18/19/21/22/23 -> ULN2803A -> K20..K25 relay coils -> Zone outputs J20..J25

When a zone is activated, the ESP32 first enables the 24 VAC rail (K1), then drives the selected relay through the ULN2803A. The ULN2803A acts as a low-side driver for the relay coils, keeping ESP32 GPIO current low while switching the 24 VAC solenoid load through the relay contacts.

## Bill of Materials

| Ref | Component | Value / Part No. | Notes |
|-----|-----------|-----------------|-------|
| U4 | ESP32 module | ESP32-WROOM-32U | External antenna (U.FL) |
| U3 | AC-DC module | HLK-PM01 | 100–240 VAC in, 5 V / 600 mA out |
| U1 | LDO regulator | AMS1117-3.3 | SOT-223 |
| U2 | Optocoupler | EL817 | Isolates the 24 VAC rail sense |
| U5 | Darlington array | ULN2803A | SOIC-18 |
| K1 | Solid-state relay | Omron G3MB-202P | Gates the 24 VAC solenoid rail (GPIO16) |
| K20–K25 | Relay ×6 | Omron G5LE-1 | SPDT, 5 V coil, 10 A / 250 VAC contacts |
| RV20–RV25 | Varistor ×6 | 68 V | Surge protection, one per zone output |
| RV1 | Varistor | 10D471K (275 VAC) | Across K1 SSR output / transformer primary |
| RV2 | Varistor | 10D471K (275 VAC) | Across mains L–N, after F1 |
| F1 | Fuse | **T1A** (time-delay) | Mains supply protection — slow-blow for transformer/HLK inrush |
| F2 | Fuse | **T2A** (time-delay) | 24 VAC supply protection — slow-blow for solenoid inrush |
| D1 | Diode | 1N4148 (0805) | 24 VAC rail sense |
| D2 | Schottky diode | SS34 (SMA) | UART 5 V back-feed block. **DNP** — bridge the pads if unfitted (back-side silk) |
| JP1 | Solder jumper | 3-way | J6 I²C-header supply select: **3V3 (default)** / 5V (back side) |
| C7 | Capacitor | 220 µF / ≥10 V | 5 V rail bulk reservoir (THT radial) |
| C1, C4 | SMD capacitors | 10 µF | Supply filtering / sense |
| C2, C3 | SMD capacitors | 22 µF | Supply filtering / sense |
| C5, C6, C20–C25 | SMD capacitors | 100 nF | EN reset (C5), ESP32 VDD (C6), zone snubbers (C20–C25) |
| R1, R3, R5–R10 | SMD resistors | 10 kΩ | Sense (R1), EN/BOOT pull-ups (R3/R7), button pull-downs (R5/R6/R9/R10) |
| R2, R11–R14 | SMD resistors | 4.7 kΩ | Sense (R2), LED series (R11/R12), I²C pull-ups (R13/R14) |
| R4, R8 | SMD resistors | 470 Ω | EN/BOOT switch series |
| R20–R25 | SMD resistors | 100 Ω | Zone snubber series |
| LED1, LED2 | LED ×2 | 0805 | IO2 status / power |
| SW1, SW2 | Tactile switch ×2 | — | EN (reset) / BOOT |
| TP1–TP3 | Test points | GND / 5V / 3V3 | |


See `manufacturing/bom/bom.csv` for the full BOM with quantities, values, and footprints.

## Wiring

### J1 — Main Supply (3-pin 5.08 mm pluggable terminal connector, MSTBA 2,5/3-G-5,08 / 250 V rated, bottom-left of board)

Mains input to the board. Also feeds J2 to supply the external transformer primary.

| Pin | Signal | Connect to |
|-----|--------|-----------|
| 1 | GND / Earth | Safety earth |
| 2 | Live | Mains live (240 VAC) |
| 3 | Neutral | Mains neutral |

### J2 — XFMR Out (2-pin screw terminal)

240 VAC output from the board to the **primary** of an external step-down transformer.

| Pin | Signal |
|-----|--------|
| 1 | Live (switched to transformer primary) |
| 2 | Neutral |

### J3 — XFMR In (2-pin screw terminal)

24 VAC input from the **secondary** of the external transformer. This is the solenoid supply rail.

| Pin | Signal |
|-----|--------|
| 1 | 24 VAC hot |
| 2 | 24 VAC common / return |

Use a suitable safety-rated 240 VAC → 24 VAC transformer (VA rating = number of valves × ~8 VA each, minimum 50 VA recommended).

### Zone Terminals (2-pin pluggable terminal connectors, KF2EDG-style, one per zone)

Each zone terminal has a switched 24 VAC output and a 24 VAC common. Connect solenoid valve wires here — polarity does not matter for standard solenoids.

| Terminal | Connector | GPIO | Relay |
|----------|-----------|------|-------|
| Station 0 | J20 | GPIO 17 | K20 |
| Station 1 | J21 | GPIO 18 | K21 |
| Station 2 | J22 | GPIO 19 | K22 |
| Station 3 | J23 | GPIO 21 | K23 |
| Station 4 | J24 | GPIO 22 | K24 |
| Station 5 | J25 | GPIO 23 | K25 |

### J4 — Button Inputs (6-pin JST XH)

Four digital inputs, each with a 10 kΩ pull-**down** to GND (R5, R6, R9, R10). Pin 2 supplies 3.3 V, so a momentary button wired from a GPIO pin to pin 2 reads **active-HIGH** (HIGH while pressed). GPIO34 and GPIO35 are input-only pins on the ESP32 (no internal pull-up/down — the external 10 kΩ resistors set their idle level).

| Pin | Signal |
|-----|--------|
| 1 | GND |
| 2 | +3.3 V |
| 3 | Button 2 (GPIO34) |
| 4 | Button 3 (GPIO35) |
| 5 | Button 0 (GPIO32) |
| 6 | Button 1 (GPIO33) |

Wire each button between pin 2 (+3.3 V) and the desired button pin.

If four buttons are not enough, R10 can be replaced with a capacitor and the four inputs wired as a resistor ladder to a single ADC pin, giving up to 16+ combinations. See the [ESPHome ADC documentation](https://esphome.io/components/sensor/adc.html) for how to read and threshold an analog resistor ladder.

### J5 — UART0 (4-pin JST XH)

For programming and serial debug. Connect a 5 V USB-to-UART adapter here. The 5 V pin feeds U1 (AMS1117-3.3) through D2, powering the ESP32 from the adapter supply without needing mains. D2 (SS34 Schottky) blocks the onboard HLK-PM01 5 V from back-feeding the adapter; it is fitted **DNP** — if you do not populate it, bridge its pads (see the back-side silk note) or the J5 5 V pin will be dead.

| Pin | Signal |
|-----|--------|
| 1 | GND |
| 2 | 5 V |
| 3 | RX (IO3) |
| 4 | TX (IO1) |

### J6 — I²C (4-pin JST XH)

General-purpose I²C bus with onboard 4.7 kΩ pull-ups (R13/R14 to 3.3 V). Suitable for displays, sensors, or expanders.

| Pin | Signal |
|-----|--------|
| 1 | GND |
| 2 | VCC — selectable by JP1: **3.3 V (default)** or 5 V |
| 3 | SDA (GPIO5) |
| 4 | SCL (GPIO4) |

**JP1 supply jumper** (back side, near J6): sets the I²C header's VCC pin. It ships bridged 1–2 = **3.3 V**. To power a 5 V peripheral, cut the 1–2 link and bridge 2–3 instead. Note the SDA/SCL pull-ups remain on 3.3 V — if a 5 V peripheral has its own pull-ups to 5 V, add an external level shifter (e.g. TCA9406) so 5 V is not presented to the ESP32 pins.

An **SSD1309** (or SSD1306) OLED display is one option; any I²C device works. ESPHome has built-in support for a wide range of I²C displays and sensors.

## GPIO Pinout

| GPIO | Function | Notes |
|------|----------|---------|
| 0 | BOOT | Pull low to enter bootloader |
| 2 | Status | Boot-mode indicator |
| 1 | UART TX | J5 — programming / debug |
| 3 | UART RX | J5 — programming / debug |
| 4 | I²C SCL | J6 — onboard 4.7 kΩ pull-up (R14) |
| 5 | I²C SDA | J6 — onboard 4.7 kΩ pull-up (R13) |
| 16 | 24V_On | Enables 24 VAC supply via SSR (K1, G3MB-202P) |
| 17 | Zone 0 output | → ULN2803A → K20 relay |
| 18 | Zone 1 output | → ULN2803A → K21 relay |
| 19 | Zone 2 output | → ULN2803A → K22 relay |
| 21 | Zone 3 output | → ULN2803A → K23 relay |
| 22 | Zone 4 output | → ULN2803A → K24 relay |
| 23 | Zone 5 output | → ULN2803A → K25 relay |
| 25 | 24V sense input | Sens\_24V — EL817 optocoupler output (D1/R1 drive the LED off the 24 VAC rail; R2/C3 filter the transistor output); HIGH when 24 VAC present |
| 32 | Button 0 | J4, 10 kΩ pull-down (R5) — active-HIGH, button pulls to +3.3 V |
| 33 | Button 1 | J4, 10 kΩ pull-down (R6) — active-HIGH |
| 34 | Button 2 | J4, 10 kΩ pull-down (R9) — active-HIGH, input-only pin, no internal pull |
| 35 | Button 3 | J4, 10 kΩ pull-down (R10) — active-HIGH, input-only pin, no internal pull |

## ESPHome Configuration

Flash the ESP32 via the J5 (UART0) header before installing the board in an enclosure. Add your secrets to `secrets.yaml`.

```yaml
esphome:
  name: sprinkler
  friendly_name: Sprinkler Controller

esp32:
  board: esp32dev

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

api:
  encryption:
    key: !secret api_key

ota:
  - platform: esphome
    password: !secret ota_password

i2c:
  sda: GPIO5
  scl: GPIO4
  scan: true

switch:
  - platform: gpio
    id: supply_24v
    pin: GPIO16
    name: "24V Supply"
    internal: true        # managed by sprinkler component via valve_open_switch
    restore_mode: ALWAYS_OFF

  - platform: gpio
    id: zone_0
    pin: GPIO17
    name: "Zone 0"
    internal: true
    restore_mode: ALWAYS_OFF

  - platform: gpio
    id: zone_1
    pin: GPIO18
    name: "Zone 1"
    internal: true
    restore_mode: ALWAYS_OFF

  - platform: gpio
    id: zone_2
    pin: GPIO19
    name: "Zone 2"
    internal: true
    restore_mode: ALWAYS_OFF

  - platform: gpio
    id: zone_3
    pin: GPIO21
    name: "Zone 3"
    internal: true
    restore_mode: ALWAYS_OFF

  - platform: gpio
    id: zone_4
    pin: GPIO22
    name: "Zone 4"
    internal: true
    restore_mode: ALWAYS_OFF

  - platform: gpio
    id: zone_5
    pin: GPIO23
    name: "Zone 5"
    internal: true
    restore_mode: ALWAYS_OFF

sprinkler:
  - id: sprinkler
    main_switch: "Sprinkler System"
    auto_advance: true
    valve_open_switch: supply_24v    # turns 24 VAC rail on/off automatically
    valves:
      - valve_switch: zone_0
        enable_switch: "Enable Zone 0"
        run_duration: 300s
        name: "Zone 0"
      - valve_switch: zone_1
        enable_switch: "Enable Zone 1"
        run_duration: 300s
        name: "Zone 1"
      - valve_switch: zone_2
        enable_switch: "Enable Zone 2"
        run_duration: 300s
        name: "Zone 2"
      - valve_switch: zone_3
        enable_switch: "Enable Zone 3"
        run_duration: 300s
        name: "Zone 3"
      - valve_switch: zone_4
        enable_switch: "Enable Zone 4"
        run_duration: 300s
        name: "Zone 4"
      - valve_switch: zone_5
        enable_switch: "Enable Zone 5"
        run_duration: 300s
        name: "Zone 5"

binary_sensor:
  - platform: gpio
    name: "Button 0"
    pin:
      number: GPIO32
      mode: INPUT
      inverted: false   # active-HIGH — button pulls to +3.3 V, 10k pull-down idles LOW
    id: button_0

  - platform: gpio
    name: "Button 1"
    pin:
      number: GPIO33
      mode: INPUT
      inverted: false
    id: button_1

  - platform: gpio
    name: "Button 2"
    pin:
      number: GPIO34
      mode: INPUT         # input-only pin — external 10k pull-down sets idle LOW
      inverted: false
    id: button_2

  - platform: gpio
    name: "Button 3"
    pin:
      number: GPIO35
      mode: INPUT         # input-only pin — external 10k pull-down sets idle LOW
      inverted: false
    id: button_3

  - platform: gpio
    name: "24V Present"
    pin:
      number: GPIO25
      mode: INPUT
    id: sens_24v
    device_class: power
    entity_category: diagnostic

  - platform: template
    name: "24V Fault"
    id: fault_24v
    device_class: problem
    filters:
      - delayed_on: 1s    # allow transformer + RC filter to charge before flagging fault
    lambda: |-
      // Fault: 24 VAC supply commanded ON but rail not detected
      return id(supply_24v).state && !id(sens_24v).state;
```

`restore_mode: ALWAYS_OFF` ensures all outputs are off on boot or after a power failure — valves never left open unintentionally.

The zone GPIO switches are marked `internal: true` so they don't appear as individual entities in Home Assistant — the `sprinkler` component exposes them as named valves instead. The **24V Supply** switch is also internal; `valve_open_switch: supply_24v` tells ESPHome to energise K1 (the 24 VAC SSR) automatically when the first valve opens and cut it after the last valve closes.

Adjust `run_duration` per zone as needed.

The ULN2803A inputs are active-high: GPIO high energises the relay coil and opens the solenoid valve.

### 24 VAC Fault Detection

GPIO25 reads the `Sens_24V` net, driven by an **EL817 optocoupler (U2)** that isolates the logic from the 24 VAC rail. On the rail side, D1 (1N4148) half-wave rectifies the 24 VAC and R1 (10 kΩ) limits the EL817 LED current. On the logic side the EL817 transistor pulls `Sens_24V` toward 3.3 V, with R2 (4.7 kΩ) and C3 (22 µF) forming the load and smoothing filter. When the rail is live the pin reads logic HIGH; when F2 blows or the transformer is absent, the LED stops conducting, C3 discharges through R2, and the pin falls to logic LOW within a few hundred milliseconds.

The **24V Fault** template sensor fires when `supply_24v` is `ON` but `sens_24v` is `OFF` — the SSR has been commanded on but 24 VAC has not appeared or has been lost, most likely a blown F2. Wire a Home Assistant automation to this entity to alert and turn off all zones on fault.

## Assembly Notes

1. **SMD first** — solder U1 (AMS1117, SOT-223), U2 (EL817), U5 (ULN2803A, SOIC-18), bypass capacitors, and resistors before installing through-hole parts. JP1 and the DNP D2 are on the **back** side.
2. **HLK-PM01 (U3)** — the module solders via its 4 pins. Ensure solid joints; this carries mains current.
3. **Relay orientation** — G5LE-1 relays are polarised. Match the notch on pin 1 to the PCB silkscreen indicator.
4. **ULN2803A (U5)** — SOIC-18 surface-mount package; cannot be socketed. Take care with orientation — pin 1 dot to silkscreen marker.
5. **ESP32 antenna clearance** — route the U.FL antenna cable away from the PCB and metal enclosure walls; keep it clear of high-voltage traces.
6. **Fuse holders** — use 5×20 mm holders per the footprint. Insert fuses after all soldering is complete.
7. **Bench test & flash** — before applying mains, connect a 5 V USB-to-UART adapter to J5 (UART0). The adapter's 5 V pin powers U1 (AMS1117-3.3), which in turn supplies 3.3 V to the ESP32. Verify 3.3 V is present on the low-voltage rail with a multimeter. Hold BOOT (GPIO0 low) and press EN to enter the bootloader, then flash ESPHome via `esphome run`. Confirm the device connects to WiFi and appears in Home Assistant. Disconnect J5.
8. **Mains power-on (no transformer)** — Leave J5 disconnected. Apply mains via J1. Verify 5 V at U2 output and 3.3 V at U1 output with a multimeter. Confirm the ESP32 boots and reconnects to Home Assistant. Disconnect mains.
9. **Full commissioning** — Wire the transformer between J2 (primary) and J3 (secondary). Connect solenoids to the zone terminals. Apply mains and test each zone from Home Assistant.

## Project Structure

```
Sprinkler System.kicad_pro    ← KiCad project file
Sprinkler System.kicad_sch    ← Root schematic
Sprinkler System.kicad_pcb    ← PCB layout
sheets/                        ← Hierarchical schematic sub-sheets
symbols/                       ← Custom symbol library (G3MB-202P)
footprints/                    ← Custom footprints (relay, fuse holder)
3d_models/                     ← Custom 3D models (.step)
manufacturing/
  gerbers/                     ← Gerber files for PCB fabrication
  drill/                       ← Excellon drill files
  pos/                         ← Pick-and-place centroid files
  bom/bom.csv                  ← Bill of materials
docs/                          ← Schematic/PCB PDFs, DRC/ERC reports
```

## Developing

VS Code tasks are provided for all KiCad CLI exports. Run them via **Terminal → Run Task** or the command palette (`Ctrl+Shift+P` → *Tasks: Run Task*). Each task pre-fills the project `.kicad_pcb` or `.kicad_sch` path — press Enter to accept or type a different path.

### Checks

| Task | Output |
|------|--------|
| KiCad: Run ERC | `docs/erc-report.txt` |
| KiCad: Run DRC | `docs/drc-report.txt` |

Run ERC and DRC before generating any fabrication outputs. Fix all errors before submitting to a board house.

### Fabrication outputs

| Task | Output |
|------|--------|
| KiCad: Export Gerbers | `manufacturing/gerbers/` |
| KiCad: Export Drill Files | `manufacturing/drill/` |
| KiCad: Export Pick-and-Place (POS) | `manufacturing/pos/` |
| KiCad: Export BOM (CSV) | `manufacturing/bom/bom.csv` |
| KiCad: Export Netlist | `manufacturing/netlist.net` |
| KiCad: Export Schematic PDF | `docs/schematic.pdf` |
| KiCad: Export PCB PDF | `docs/pcb.pdf` |
| KiCad: Export STEP (3D Model) | `docs/board.step` |
| KiCad: Full Fabrication Export | All of the above (except STEP), run in sequence |

**KiCad: Full Fabrication Export** is the normal pre-submission task — it runs Gerbers, drill, POS, BOM, schematic PDF, and PCB PDF in order.

### Requirements

- [KiCad 8+](https://www.kicad.org/download/) with the CLI (`kicad-cli`) on your PATH, or set `kicad.cliPath` in VS Code settings to the full path of the executable.
