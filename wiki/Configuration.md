# Configuration

All tunable values live in a single file:

```
src/ReplicatedStorage/AirplaneConfig.lua
```

Both the server and client `require()` this module, so a change here applies everywhere automatically.

## Full Reference

### Physics

| Key | Default | Description |
|-----|---------|-------------|
| `MaxThrust` | `800` | Maximum engine force (studs/s²) |
| `MinThrust` | `0` | Minimum engine force |
| `ThrustAcceleration` | `80` | Unused acceleration ramp (reserved) |
| `LiftCoefficient` | `2.5` | Multiplier for lift = coeff × speed² × 0.01 |
| `DragCoefficient` | `0.08` | Multiplier for drag = coeff × speed² |
| `RollSpeed` | `55` | Max roll rate in °/s |
| `PitchSpeed` | `40` | Max pitch rate in °/s |
| `YawSpeed` | `20` | Max yaw rate in °/s |
| `MaxSpeed` | `350` | Absolute velocity cap (studs/s) |
| `StallSpeed` | `40` | Airspeed below which lift = 0 (studs/s) |
| `Gravity` | `196.2` | Downward force — match `Workspace.Gravity` |

### Throttle

| Key | Default | Description |
|-----|---------|-------------|
| `ThrottleStep` | `0.05` | Throttle change per frame a key is held (5%) |

### Spawn

| Key | Default | Description |
|-----|---------|-------------|
| `SpawnAltitude` | `100` | Y coordinate where planes spawn |
| `SpawnPosition` | `Vector3(0,100,0)` | Base spawn position (±20 stud random offset applied) |

### Camera

| Key | Default | Description |
|-----|---------|-------------|
| `CameraDistance` | `30` | Distance behind the plane (studs) |
| `CameraHeight` | `8` | Height above the plane's CFrame origin |
| `CameraLerpSpeed` | `0.12` | How quickly the camera follows (0 = frozen, 1 = instant) |

### HUD

| Key | Default | Description |
|-----|---------|-------------|
| `HUDUpdateInterval` | `0.05` | Minimum seconds between HUD updates (currently unused; HUD updates on each FlightData event) |

### Airplane Dimensions

These control the Part sizes used by `AirplaneBuilder`:

| Key | Default | Description |
|-----|---------|-------------|
| `Body.Size` | `(14, 3, 5)` | Fuselage dimensions |
| `Wing.Size` | `(4, 0.6, 20)` | Each wing panel |
| `Tail.Size` | `(3, 4, 1)` | Vertical stabiliser |
| `HorizontalStabilizer.Size` | `(3, 0.5, 8)` | Each horizontal stab panel |
| `Engine.Size` | `(3, 3, 3)` | Engine nacelle |
| `Propeller.Size` | `(0.5, 12, 0.5)` | Propeller disc |

## Example Tweaks

### Make it faster and more agile

```lua
MaxThrust  = 1200,
MaxSpeed   = 500,
RollSpeed  = 90,
PitchSpeed = 70,
```

### Make it feel heavier / more realistic

```lua
LiftCoefficient = 1.8,
DragCoefficient = 0.12,
StallSpeed      = 60,
ThrottleStep    = 0.02,
```

### Tighter follow camera

```lua
CameraDistance  = 20,
CameraHeight    = 5,
CameraLerpSpeed = 0.25,
```
