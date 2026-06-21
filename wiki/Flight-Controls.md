# Flight Controls

## Keyboard Reference

### Primary Flight Controls

| Key | Action | Axis |
|-----|--------|------|
| `W` / `↑` | Pitch nose **down** | Pitch |
| `S` / `↓` | Pitch nose **up** | Pitch |
| `A` / `←` | Roll **left** | Roll |
| `D` / `→` | Roll **right** | Roll |
| `Q` | Yaw **left** (rudder) | Yaw |
| `E` | Yaw **right** (rudder) | Yaw |

### Throttle

| Key | Action |
|-----|--------|
| `Left Shift` | Increase throttle (+5% per frame held) |
| `Left Ctrl` | Decrease throttle (−5% per frame held) |

## Flight Tips

### Taking Off
1. Hold `Left Shift` to build throttle to ~70–100%.
2. The plane lifts off automatically once airspeed exceeds the **stall speed** (40 u/s by default).
3. Hold `S` briefly to raise the nose once airborne.

### Cruising
- Maintain throttle around **60–80%** for level flight.
- Use small `W`/`S` inputs to trim altitude.
- Roll with `A`/`D` then pitch to turn — coordinated turns are more efficient.

### Landing
1. Reduce throttle to ~20% and descend gradually.
2. Keep airspeed above the stall speed (40 u/s) until just before touchdown.
3. Pitch nose up (`S`) to flare just before ground contact.

## Control Feel Tuning

All rates are configurable in [`AirplaneConfig.lua`](Configuration):

| Config Key | Default | Effect |
|-----------|---------|--------|
| `RollSpeed` | 55 | Degrees/s of roll rate |
| `PitchSpeed` | 40 | Degrees/s of pitch rate |
| `YawSpeed` | 20 | Degrees/s of yaw rate |
| `ThrottleStep` | 0.05 | Throttle change per held frame |
