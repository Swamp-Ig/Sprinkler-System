# Assembly Notes

1. **SMD first** — solder U1 (AMS1117, SOT-223), U2 (EL817), U5 (ULN2803A, SOIC-18), bypass capacitors, and resistors before installing through-hole parts. JP1 (I²C supply jumper) is on the **back** side.

2. **HLK-PM01 (U3)** — the module solders via its 4 pins. Ensure solid joints; this carries mains current.

3. **Relay orientation** — G5LE-1 relays are polarised. Match the notch on pin 1 to the PCB silkscreen indicator.

4. **ULN2803A (U5)** — SOIC-18 surface-mount package; cannot be socketed. Take care with orientation — pin 1 dot to silkscreen marker.

5. **ESP32 antenna clearance** — route the U.FL antenna cable away from the PCB and metal enclosure walls; keep it clear of high-voltage traces.

6. **Fuse holders** — use 5×20 mm holders per the footprint. Insert fuses after all soldering is complete.

7. **Bench test & flash** — before applying mains, connect a 5 V USB-to-UART adapter to J5 (UART0). The adapter's 5 V pin powers U1 (AMS1117-3.3), which supplies 3.3 V to the ESP32. Verify 3.3 V is present on the low-voltage rail with a multimeter. Hold BOOT (GPIO0 low) and press EN to enter the bootloader, then flash ESPHome via `esphome run`. Confirm the device connects to WiFi and appears in Home Assistant. Disconnect J5.

8. **Mains power-on (no transformer)** — leave J5 disconnected. Apply mains via J1. Verify 5 V at U3 output and 3.3 V at U1 output with a multimeter. Confirm the ESP32 boots and reconnects to Home Assistant. Disconnect mains.

9. **Full commissioning** — wire the transformer between J2 (primary) and J3 (secondary). Connect solenoids to the zone terminals. Apply mains and test each zone from Home Assistant.

---

## Conformal Coating

Even inside a sealed enclosure, condensation can form on the PCB during temperature cycling. Apply conformal coating after final assembly and testing:

- **Mask before coating**: the mains/transformer terminals (J1–J3), pluggable zone connectors (J20–J25), fuse holders, the ESP32 U.FL connector, and the UART header (J5).
- Apply 2–3 thin coats of acrylic or silicone conformal coating to both sides of the PCB.
- Allow to fully cure before installing in the enclosure.
