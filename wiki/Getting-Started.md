# Getting Started

## Prerequisites

| Tool | Version | Link |
|------|---------|------|
| Roblox Studio | Latest | [roblox.com/create](https://www.roblox.com/create) |
| Rojo | 7.x | [rojo.space](https://rojo.space) |
| Git | Any | [git-scm.com](https://git-scm.com) |

## 1 — Clone the Repository

```bash
git clone https://github.com/prasenjeet/roblox-game
cd roblox-game
```

## 2 — Install the Rojo Studio Plugin

1. Open Roblox Studio.
2. Go to **Plugins → Manage Plugins → Search "Rojo"**.
3. Install the official **Rojo** plugin by Roblox.

## 3 — Serve the Project

In your terminal, inside the repo root:

```bash
rojo serve
```

You should see:

```
Rojo server listening on port 34872
```

## 4 — Connect Studio

1. In Roblox Studio click **Plugins → Rojo → Connect**.
2. Rojo syncs all scripts from `src/` into the live place.
3. Press **Play (F5)** to test immediately.

## Project Structure

```
roblox-game/
├── default.project.json          # Rojo project definition
├── wiki/                         # Documentation (these pages)
└── src/
    ├── ReplicatedStorage/
    │   ├── AirplaneConfig.lua    # Shared constants
    │   └── Modules/
    │       ├── RemoteEvents.lua  # Event wiring
    │       └── AirplaneBuilder.lua # Model construction
    ├── ServerScriptService/
    │   └── AirplaneServer.server.lua  # Physics & replication
    ├── StarterPlayerScripts/
    │   └── AirplaneController.client.lua  # Input & camera
    └── StarterGui/
        └── FlightHUD/
            └── FlightHUD.lua     # Heads-up display
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Scripts not appearing in Studio | Make sure `rojo serve` is running and you clicked **Connect** |
| Airplane not spawning | Open the Output window (`View → Output`) and check for errors |
| Camera stuck | The character's HumanoidRootPart is anchored during flight; respawn to reset |
