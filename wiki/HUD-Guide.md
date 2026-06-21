# HUD Guide

The **Flight HUD** is a client-side overlay that displays real-time flight data. It is built entirely in Lua — no external assets or images are required.

## Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────────┐                             ┌──────┐         │
│  │  FLIGHT DATA │                             │ THR  │         │
│  │              │                             │      │         │
│  │ SPD: 123.4   │                             │  ██  │         │
│  │ ALT: 250.0   │                             │  ██  │  75%    │
│  │ PCH:  -5.2°  │                             │  ██  │         │
│  │ ROL:  10.0°  │                             └──────┘         │
│  └──────────────┘                                              │
│                                                                 │
│         W/S: Pitch  |  A/D: Roll  |  Q/E: Yaw  | Shift/Ctrl   │
└─────────────────────────────────────────────────────────────────┘
```

## Instruments

### Left Panel — Flight Data

| Label | Unit | Source |
|-------|------|--------|
| **SPD** | studs/s | Airspeed along look vector |
| **ALT** | studs | `Fuselage.Position.Y` |
| **PCH** | degrees | Pitch angle (nose above/below horizon) |
| **ROL** | degrees | Roll angle (bank left/right) |

- Positive **PCH** = nose above horizon (climbing).
- Negative **PCH** = nose below horizon (descending).
- Positive **ROL** = right wing down.

### Right Panel — Throttle Bar

A vertical bar that fills from bottom to top:

| Colour | Throttle |
|--------|---------|
| Red | 0% |
| Orange | ~50% |
| Green | 100% |

The percentage label beneath the bar shows the exact throttle value.

### Bottom Bar — Controls Hint

Always-visible reference for keyboard controls. Can be hidden by setting `Transparency = 1` on the `HintFrame` in `FlightHUD.lua`.

## Update Rate

The HUD is driven by `RemoteEvent FlightData`, which the server fires every `Heartbeat` (~60 times/s). The UI updates exactly when new data arrives — no client-side polling.

## Customising the HUD

All styling is in `src/StarterGui/FlightHUD/FlightHUD.lua`. Key variables:

| Variable | What it controls |
|----------|-----------------|
| `leftPanel` size/position | Location of the data panel |
| `rightPanel` size/position | Location of the throttle bar |
| `Color3.fromRGB(...)` in labels | Text colours |
| `throttleBar.BackgroundColor3` formula | Bar colour gradient |
