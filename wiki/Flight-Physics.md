# Flight Physics

Physics are computed every `Heartbeat` in `AirplaneServer.server.lua`. All forces act on the fuselage via Roblox's `BodyVelocity` and `BodyAngularVelocity` constraints.

## Forces

### Thrust

```
thrust = throttle × MaxThrust
```

Applied along the airplane's **look vector** (nose direction). `MaxThrust` defaults to 800 studs/s².

### Lift

Lift only activates above **stall speed**:

```
if airspeed > StallSpeed then
    liftForce = LiftCoefficient × airspeed² × 0.01
end
```

- `LiftCoefficient` = 2.5 (default)
- `StallSpeed` = 40 u/s
- Lift acts along the airplane's **up vector**

Below stall speed the plane descends under gravity alone — realistic stall behaviour.

### Drag

Drag opposes the **total velocity** (not just forward velocity):

```
dragForce = DragCoefficient × speed²
```

- `DragCoefficient` = 0.08 (default)
- Subtracted from forward thrust force

### Gravity

A constant downward force of `196.2` studs/s² (matches Roblox's `Workspace.Gravity`):

```
gravity = Vector3.new(0, -196.2, 0)
```

Added to the net linear force every frame.

## Velocity Integration

```lua
netLinear    = lookVec * (thrust - drag)
             + upVec   * liftForce
             + gravity

targetVelocity = currentVelocity + netLinear * dt
```

The result is clamped to `MaxSpeed` (350 u/s) before being written to `BodyVelocity`.

## Angular Velocity

Rotation is direct — input axes map to angular rates with no inertia:

| Input | Angular axis | Rate constant |
|-------|-------------|---------------|
| Pitch (W/S) | `RightVector` | `PitchSpeed` = 40 °/s |
| Roll (A/D) | `LookVector` | `RollSpeed` = 55 °/s |
| Yaw (Q/E) | `UpVector` | `YawSpeed` = 20 °/s |

```lua
targetAngVel = rightVec * (-pitch × PitchSpeed)
             + lookVec  * (-roll  × RollSpeed)
             + upVec    * (-yaw   × YawSpeed)
```

When no input is held, `BodyAngularVelocity` is set to zero — the plane holds its attitude.

## Speed Envelope

| Regime | Behaviour |
|--------|-----------|
| 0 – 40 u/s | Stall — no lift, gravity pulls down |
| 40 – 150 u/s | Normal flight — lift grows with speed² |
| 150 – 350 u/s | High speed — drag increases, throttle needed to sustain |
| > 350 u/s | Capped — `MaxSpeed` clamp applied |

## Tuning Guide

All constants live in `AirplaneConfig.lua`. Key interactions:

- **Higher `LiftCoefficient`** → plane climbs more easily, may become unstable at high speed.
- **Lower `DragCoefficient`** → higher top speed, slower deceleration.
- **Lower `StallSpeed`** → easier to stay airborne at low throttle.
- **Higher `MaxThrust`** → faster acceleration and climb rate.
