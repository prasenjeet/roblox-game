# Game Architecture

## Overview

The game follows Roblox's standard **client–server** split. All physics authority lives on the server; the client only reads input and drives the camera.

```
┌─────────────────────────────────────────────────────┐
│                   SERVER                            │
│                                                     │
│  AirplaneServer.server.lua                          │
│  ├── Heartbeat loop (physics step)                  │
│  ├── BodyVelocity / BodyAngularVelocity movers      │
│  └── Fires FlightData → client every frame          │
└──────────────┬──────────────────────────────────────┘
               │  RemoteEvent: UpdateFlight (20 Hz)
               │  RemoteFunction: RequestAirplane
               │  RemoteEvent: FlightData (60 Hz)
┌──────────────▼──────────────────────────────────────┐
│                   CLIENT                            │
│                                                     │
│  AirplaneController.client.lua                      │
│  ├── RenderStepped: reads keyboard input            │
│  ├── Sends input packet to server at 20 Hz          │
│  └── Updates scriptable camera each frame           │
│                                                     │
│  FlightHUD.lua                                      │
│  └── Listens for FlightData, updates UI labels      │
└─────────────────────────────────────────────────────┘
```

## Module Map

### `ReplicatedStorage/AirplaneConfig.lua`
Shared constant table. Both server and client `require()` this. Change values here to tune physics or camera without touching logic scripts.

### `ReplicatedStorage/Modules/RemoteEvents.lua`
Idempotent setup module — creates the `AirplaneEvents` folder and all RemoteEvents/RemoteFunctions on first `require`, returns the same objects on subsequent calls. Must be required on both sides before use.

### `ReplicatedStorage/Modules/AirplaneBuilder.lua`
Purely constructive — builds and welds the airplane model from primitive `Part` instances. Attaches `BodyVelocity` and `BodyAngularVelocity` to the fuselage. Stateless: call `Build(player)` to get a new model, `Destroy(model)` to remove it.

### `ServerScriptService/AirplaneServer.server.lua`
Authoritative physics loop. Per-player state table holds throttle, speed, and the latest input packet. Each `Heartbeat`:
1. Integrates throttle from `throttleDelta`.
2. Computes thrust, lift, drag, gravity forces.
3. Sets `BodyVelocity.Velocity` and `BodyAngularVelocity.AngularVelocity`.
4. Fires `FlightData` to the owning client.

### `StarterPlayerScripts/AirplaneController.client.lua`
Runs on the client only. Polls `UserInputService` each `RenderStepped`, accumulates axis values, and fires `UpdateFlight` to the server at 20 Hz. Also manages the scriptable follow-camera.

### `StarterGui/FlightHUD/FlightHUD.lua`
Builds the HUD entirely in code (no external assets needed). Subscribes to `FlightData` events and updates labels and the throttle bar each time data arrives.

## Data Flow Sequence

```
Player presses W
  → RenderStepped: inputPitch = -1
  → Every 50 ms: FireServer(UpdateFlight, {pitch=-1, ...})
    → Server Heartbeat: applies pitch rate to BodyAngularVelocity
    → Server: FireClient(FlightData, {speed, altitude, ...})
      → Client HUD updates labels
```

## Multiplayer

Each player gets their own airplane model tagged with their `UserId`. The server `airplanes` table is keyed by `UserId`, so players are fully isolated — one player's input cannot affect another's airplane.
