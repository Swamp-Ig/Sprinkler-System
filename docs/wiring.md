# Wiring & GPIO Reference

## Connectors

### J1 — Main Supply
3-pin 5.0 mm Phoenix PT-series terminal block (PT 1,5/3-5.0, mains-rated), bottom-left of board. Mains input; also feeds J2 to supply the external transformer primary.

| Pin | Signal | Connect to |
|-----|--------|-----------|
| 1 | GND / Earth | Safety earth |
| 2 | Live | Mains live (240 VAC) |
| 3 | Neutral | Mains neutral |

### J2 — XFMR Out
2-pin screw terminal. 240 VAC output from the board to the **primary** of an external step-down transformer.

| Pin | Signal |
|-----|--------|
| 1 | Live (switched to transformer primary via K1 SSR) |
| 2 | Neutral |

### J3 — XFMR In
2-pin pluggable terminal (KF2EDG-style). 24 VAC input from the **secondary** of the external transformer — the solenoid supply rail.

| Pin | Signal |
|-----|--------|
| 1 | 24 VAC hot |
| 2 | 24 VAC common / return |

Use a safety-rated 240 VAC → 24 VAC transformer. VA rating: number of simultaneously-running valves × ~8 VA each, minimum 50 VA recommended.

### Zone Terminals — J20–J25
2-pin pluggable terminal connectors (KF2EDG-style), one per zone. Each has a switched 24 VAC output and a 24 VAC common. Polarity does not matter for standard solenoids.

| Terminal | Connector | GPIO | Relay |
|----------|-----------|------|-------|
| Station 0 | J20 | GPIO 17 | K20 |
| Station 1 | J21 | GPIO 18 | K21 |
| Station 2 | J22 | GPIO 19 | K22 |
| Station 3 | J23 | GPIO 21 | K23 |
| Station 4 | J24 | GPIO 22 | K24 |
| Station 5 | J25 | GPIO 23 | K25 |

Station 0 (J20/GPIO17/K20) can optionally be wired to a pump relay instead of a solenoid — see [ESPHome Configuration](esphome.md#optional-pump-relay).

### J4 — Button Inputs
6-pin JST XH. Four digital inputs with 10 kΩ pull-**down** resistors to GND (R5, R8, R10, R11). Pin 2 supplies 3.3 V; a button wired from a GPIO pin to pin 2 reads **active-HIGH** (HIGH while pressed). GPIO34 and GPIO35 are input-only pins (no internal pull — the external 10 kΩ resistors set their idle level).

| Pin | Signal |
|-----|--------|
| 1 | GND |
| 2 | +3.3 V |
| 3 | Button 2 (GPIO34) |
| 4 | Button 3 (GPIO35) |
| 5 | Button 0 (GPIO32) |
| 6 | Button 1 (GPIO33) |

Wire each button between pin 2 (+3.3 V) and the desired button pin.

If more than four inputs are needed, GPIO34 (pin 3) can be wired as a resistor ladder to give 16+ combinations on a single ADC input. GPIO34 is preferred for this as it is input-only with no competing functions. See the [ESPHome ADC documentation](https://esphome.io/components/sensor/adc.html).

### J5 — UART0
4-pin JST XH. For programming and serial debug. Connect a 5 V USB-to-UART adapter here — the adapter's 5 V powers U1 (AMS1117-3.3) and the ESP32 without needing mains. **Power from one source at a time** — do not connect the UART adapter's 5 V while the board is also running from mains.

| Pin | Signal |
|-----|--------|
| 1 | GND |
| 2 | 5 V |
| 3 | RX (IO3) |
| 4 | TX (IO1) |

### J6 — I²C
4-pin JST XH. General-purpose I²C bus with onboard 4.7 kΩ pull-ups (R13/R14 to 3.3 V). Suitable for displays, sensors, or expanders.

| Pin | Signal |
|-----|--------|
| 1 | GND |
| 2 | VCC — selectable by JP1: **3.3 V (default)** or 5 V |
| 3 | SDA (GPIO5) |
| 4 | SCL (GPIO4) |

**JP1 supply jumper** (back side, near J6): ships bridged 1–2 = **3.3 V**. To power a 5 V peripheral, cut the 1–2 link and bridge 2–3. Note the SDA/SCL pull-ups remain on 3.3 V — if a 5 V peripheral drives the lines to 5 V, add a level shifter (e.g. TCA9406) to protect the ESP32 pins.

---

## GPIO Pinout

| GPIO | Function | Notes |
|------|----------|-------|
| 0 | BOOT | Pull low to enter bootloader |
| 1 | UART TX | J5 — programming / debug |
| 2 | Status LED | Boot-mode indicator |
| 3 | UART RX | J5 — programming / debug |
| 4 | I²C SCL | J6 — onboard 4.7 kΩ pull-up (R14) |
| 5 | I²C SDA | J6 — onboard 4.7 kΩ pull-up (R13) |
| 16 | 24V_On | Enables 24 VAC supply via K1 (G3MB-202P SSR) |
| 17 | Zone 0 | → ULN2803A → K20 relay (or pump relay — optional) |
| 18 | Zone 1 | → ULN2803A → K21 relay |
| 19 | Zone 2 | → ULN2803A → K22 relay |
| 21 | Zone 3 | → ULN2803A → K23 relay |
| 22 | Zone 4 | → ULN2803A → K24 relay |
| 23 | Zone 5 | → ULN2803A → K25 relay |
| 25 | 24V sense | EL817 optocoupler output — HIGH when 24 VAC rail is live |
| 32 | Button 0 | J4, 10 kΩ pull-down (R5) — active-HIGH |
| 33 | Button 1 | J4, 10 kΩ pull-down (R8) — active-HIGH |
| 34 | Button 2 | J4, 10 kΩ pull-down (R10) — active-HIGH, input-only |
| 35 | Button 3 | J4, 10 kΩ pull-down (R11) — active-HIGH, input-only |
