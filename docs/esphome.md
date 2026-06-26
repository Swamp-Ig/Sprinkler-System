# ESPHome Configuration

Flash the ESP32 via the J5 (UART0) header before installing the board in an enclosure. Add your secrets to `secrets.yaml`.

## Base Configuration (6 zones, no pump)

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

globals:
  - id: fault_latched
    type: bool
    restore_value: true
    initial_value: 'false'

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

button:
  - platform: template
    name: "Reset 24V Fault"
    entity_category: config
    on_press:
      - globals.set:
          id: fault_latched
          value: 'false'

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
      return id(supply_24v).state && !id(sens_24v).state;
    on_press:
      then:
        - globals.set:
            id: fault_latched
            value: 'true'
        - sprinkler.stop: sprinkler

  - platform: template
    name: "24V Fault Latched"
    id: fault_latched_sensor
    device_class: problem
    entity_category: diagnostic
    lambda: 'return id(fault_latched);'

# Stop the sprinkler immediately if it is started while a fault is latched
interval:
  - interval: 500ms
    then:
      - if:
          condition:
            lambda: 'return id(fault_latched) && id(sprinkler).is_running();'
          then:
            - sprinkler.stop: sprinkler
```

`restore_mode: ALWAYS_OFF` ensures all outputs are off on boot or after a power failure — valves never left open unintentionally.

The zone GPIO switches are marked `internal: true` so they don't appear as individual entities in Home Assistant — the `sprinkler` component exposes them as named valves instead. The **24V Supply** switch is also internal; `valve_open_switch: supply_24v` tells ESPHome to energise K1 (the 24 VAC SSR) automatically when the first valve opens and cut it after the last valve closes.

Adjust `run_duration` per zone as needed.

---

## 24 VAC Fault Detection

GPIO25 reads the `Sens_24V` net, driven by an **EL817 optocoupler (U2)** that isolates the logic from the 24 VAC rail. On the rail side, D1 (1N4148) half-wave rectifies the 24 VAC and R1 (10 kΩ) limits the EL817 LED current. On the logic side the EL817 transistor pulls `Sens_24V` toward 3.3 V, with R2 (4.7 kΩ) and C3 (22 µF) forming the load and smoothing filter. When the rail is live the pin reads HIGH; when F2 blows or the transformer is absent, C3 discharges through R2 and the pin falls to LOW within a few hundred milliseconds.

**Fault behaviour**: when `supply_24v` is `ON` but `sens_24v` is `OFF`, the `24V Fault` sensor fires. This latches the `fault_latched` global, immediately stops the sprinkler, and the 500 ms interval prevents it from restarting. The latch persists across power cycles (`restore_value: true`).

**To clear**: press the **Reset 24V Fault** button in Home Assistant (or via the ESPHome API) after the underlying cause is fixed (e.g. replace F2). Add a Home Assistant automation on `fault_latched_sensor` to alert when a fault is detected.

---

## Optional: Pump Relay

Zone 0 (J20 / GPIO17 / K20) can be repurposed as a pump relay, giving 5 irrigation zones (Zones 1–5) plus a pump. This is useful when a booster pump or pump start relay is needed to maintain pressure.

In a pump-equipped system the valve opens first (solenoid energises, path is clear), then the pump starts — and the pump stops before the valve closes. This sequencing prevents water hammer. Replace the `valve_open_switch` and `valves` sections as follows:

```yaml
switch:
  # zone_0 becomes the pump relay
  - platform: gpio
    id: pump_relay
    pin: GPIO17
    name: "Pump"
    internal: true
    restore_mode: ALWAYS_OFF

  # supply_24v and zone_1–zone_5 unchanged

sprinkler:
  - id: sprinkler
    main_switch: "Sprinkler System"
    auto_advance: true
    valve_open_switch: pump_relay   # pump turns on/off with valves
    valves:
      # zone_0 removed — now the pump relay
      - valve_switch: zone_1
        enable_switch: "Enable Zone 1"
        run_duration: 300s
        name: "Zone 1"
      # ... zone_2 through zone_5
```

For precise pump start/stop delays (to control sequencing and water hammer), see the [ESPHome Sprinkler Controller documentation](https://esphome.io/components/sprinkler.html).
