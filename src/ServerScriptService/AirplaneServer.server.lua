-- SERVER: manages airplane creation, physics simulation, and replication

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules
local Modules       = ReplicatedStorage:WaitForChild("Modules", 10)
local RemoteEvents  = require(Modules:WaitForChild("RemoteEvents", 10))
local AirplaneBuilder = require(Modules:WaitForChild("AirplaneBuilder", 10))
local Config        = require(ReplicatedStorage:WaitForChild("AirplaneConfig", 10))

-- Table of active airplane states keyed by UserId
-- state = { model, fuselage, throttle, velocity, pitch, roll, yaw }
local airplanes = {}

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function clamp(v, lo, hi)
	return math.max(lo, math.min(hi, v))
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

-- ─── Create / destroy ─────────────────────────────────────────────────────────

local function spawnAirplane(player)
	local existing = airplanes[player.UserId]
	if existing then
		AirplaneBuilder.Destroy(existing.model)
		airplanes[player.UserId] = nil
	end

	local model = AirplaneBuilder.Build(player)
	local fuselage = model.PrimaryPart

	-- Place above spawn
	local spawnPos = Config.SpawnPosition + Vector3.new(
		math.random(-20, 20), 0, math.random(-20, 20))
	model:SetPrimaryPartCFrame(CFrame.new(spawnPos))

	airplanes[player.UserId] = {
		model     = model,
		fuselage  = fuselage,
		throttle  = 0,
		speed     = 0,
		pitchRate = 0,
		rollRate  = 0,
		yawRate   = 0,
		-- input deltas sent from client each frame
		input = { pitch = 0, roll = 0, yaw = 0, throttleDelta = 0 },
	}

	return model
end

local function removeAirplane(player)
	local state = airplanes[player.UserId]
	if state then
		AirplaneBuilder.Destroy(state.model)
		airplanes[player.UserId] = nil
	end
end

-- ─── Remote handlers ──────────────────────────────────────────────────────────

RemoteEvents.RequestAirplane.OnServerInvoke = function(player)
	local model = spawnAirplane(player)
	return model
end

RemoteEvents.UpdateFlight.OnServerEvent:Connect(function(player, inputData)
	local state = airplanes[player.UserId]
	if not state then return end
	-- Validate incoming data
	state.input.pitch         = clamp(tonumber(inputData.pitch) or 0, -1, 1)
	state.input.roll          = clamp(tonumber(inputData.roll)  or 0, -1, 1)
	state.input.yaw           = clamp(tonumber(inputData.yaw)   or 0, -1, 1)
	state.input.throttleDelta = clamp(tonumber(inputData.throttleDelta) or 0, -1, 1)
end)

-- ─── Physics step ─────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function(dt)
	for userId, state in pairs(airplanes) do
		local fuselage = state.fuselage
		if not fuselage or not fuselage.Parent then
			airplanes[userId] = nil
			continue
		end

		local inp = state.input
		local cfg = Config

		-- Throttle
		state.throttle = clamp(
			state.throttle + inp.throttleDelta * cfg.ThrottleStep,
			0, 1)

		-- Thrust force → acceleration along look vector
		local thrust    = state.throttle * cfg.MaxThrust
		local lookVec   = fuselage.CFrame.LookVector
		local rightVec  = fuselage.CFrame.RightVector
		local upVec     = fuselage.CFrame.UpVector

		-- Current speed (project velocity onto look vector for airspeed)
		local vel       = fuselage.AssemblyLinearVelocity
		local airspeed  = vel:Dot(lookVec)
		state.speed     = math.max(0, airspeed)

		-- Lift: proportional to speed², zero below stall
		local liftForce = 0
		if airspeed > cfg.StallSpeed then
			liftForce = cfg.LiftCoefficient * airspeed * airspeed * 0.01
		end

		-- Drag: opposes motion
		local speedMag  = vel.Magnitude
		local dragForce = cfg.DragCoefficient * speedMag * speedMag

		-- Net forces
		local forwardForce = thrust - dragForce
		local gravity      = Vector3.new(0, -cfg.Gravity, 0)

		local netLinear    = lookVec * forwardForce
			+ upVec * liftForce
			+ gravity

		-- Target velocity: integrate
		local targetVelocity = vel + netLinear * dt
		-- Clamp magnitude
		if targetVelocity.Magnitude > cfg.MaxSpeed then
			targetVelocity = targetVelocity.Unit * cfg.MaxSpeed
		end

		-- Apply angular rates from input
		local targetAngVel =
			rightVec * (-inp.pitch * cfg.PitchSpeed) +
			lookVec  * (-inp.roll  * cfg.RollSpeed)  +
			upVec    * (-inp.yaw   * cfg.YawSpeed)

		-- Smooth angular velocity
		local bav = fuselage:FindFirstChild("BodyAngularVelocity")
		local bv  = fuselage:FindFirstChild("BodyVelocity")

		if bv then
			bv.Velocity = targetVelocity
		end
		if bav then
			bav.AngularVelocity = targetAngVel
		end

		-- Broadcast flight data back to owning client for HUD
		local player = Players:GetPlayerByUserId(userId)
		if player then
			RemoteEvents.FlightData:FireClient(player, {
				speed    = math.floor(airspeed * 10) / 10,
				altitude = math.floor(fuselage.Position.Y * 10) / 10,
				throttle = math.floor(state.throttle * 100),
				pitch    = math.floor(math.deg(math.asin(clamp(lookVec.Y, -1, 1))) * 10) / 10,
				roll     = math.floor(math.deg(math.asin(clamp(rightVec.Y, -1, 1))) * 10) / 10,
			})
		end
	end
end)

-- ─── Player lifecycle ─────────────────────────────────────────────────────────

Players.PlayerRemoving:Connect(removeAirplane)

print("[AirplaneServer] Loaded")
