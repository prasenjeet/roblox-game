-- CLIENT: reads input, sends to server, drives camera

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules      = ReplicatedStorage:WaitForChild("Modules", 10)
local RemoteEvents = require(Modules:WaitForChild("RemoteEvents", 10))
local Config       = require(ReplicatedStorage:WaitForChild("AirplaneConfig", 10))

local LocalPlayer  = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

-- ─── State ────────────────────────────────────────────────────────────────────

local airplane      = nil   -- model
local fuselage      = nil
local isFlying      = false
local sendAccum     = 0
local SEND_RATE     = 1 / 20  -- 20 Hz to server

-- Input axes (accumulated per frame, sent at SEND_RATE)
local inputPitch         = 0
local inputRoll          = 0
local inputYaw           = 0
local inputThrottleDelta = 0

-- ─── Request airplane from server ─────────────────────────────────────────────

local function requestAirplane()
	airplane = RemoteEvents.RequestAirplane:InvokeServer()
	if not airplane then
		warn("[AirplaneController] Server did not return an airplane model")
		return
	end
	fuselage = airplane:WaitForChild("Fuselage", 5)
	isFlying = true

	-- Hide character
	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = true end
	end

	Camera.CameraType = Enum.CameraType.Scriptable
end

-- ─── Input reading ────────────────────────────────────────────────────────────

local KEY_MAP = {
	-- Pitch
	[Enum.KeyCode.W]    = function() inputPitch = inputPitch - 1 end,
	[Enum.KeyCode.S]    = function() inputPitch = inputPitch + 1 end,
	[Enum.KeyCode.Up]   = function() inputPitch = inputPitch - 1 end,
	[Enum.KeyCode.Down] = function() inputPitch = inputPitch + 1 end,
	-- Roll
	[Enum.KeyCode.A]    = function() inputRoll = inputRoll - 1 end,
	[Enum.KeyCode.D]    = function() inputRoll = inputRoll + 1 end,
	[Enum.KeyCode.Left] = function() inputRoll = inputRoll - 1 end,
	[Enum.KeyCode.Right]= function() inputRoll = inputRoll + 1 end,
	-- Yaw
	[Enum.KeyCode.Q]    = function() inputYaw = inputYaw - 1 end,
	[Enum.KeyCode.E]    = function() inputYaw = inputYaw + 1 end,
	-- Throttle
	[Enum.KeyCode.LeftShift]  = function() inputThrottleDelta = inputThrottleDelta + 1 end,
	[Enum.KeyCode.LeftControl]= function() inputThrottleDelta = inputThrottleDelta - 1 end,
}

local function readInput()
	inputPitch         = 0
	inputRoll          = 0
	inputYaw           = 0
	inputThrottleDelta = 0

	for key, fn in pairs(KEY_MAP) do
		if UserInputService:IsKeyDown(key) then
			fn()
		end
	end

	-- Clamp axes
	inputPitch         = math.clamp(inputPitch, -1, 1)
	inputRoll          = math.clamp(inputRoll, -1, 1)
	inputYaw           = math.clamp(inputYaw, -1, 1)
	inputThrottleDelta = math.clamp(inputThrottleDelta, -1, 1)
end

-- ─── Camera ───────────────────────────────────────────────────────────────────

local camOffset = CFrame.new(
	-Config.CameraDistance, Config.CameraHeight, 0)

local currentCamCF = CFrame.new(0, Config.SpawnAltitude, 0)

local function updateCamera()
	if not fuselage or not fuselage.Parent then return end
	local targetCF = fuselage.CFrame * camOffset
	currentCamCF = currentCamCF:Lerp(targetCF, Config.CameraLerpSpeed)
	Camera.CFrame = CFrame.lookAt(currentCamCF.Position, fuselage.Position)
end

-- ─── Main loop ────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function(dt)
	if not isFlying then return end

	readInput()
	updateCamera()

	sendAccum = sendAccum + dt
	if sendAccum >= SEND_RATE then
		sendAccum = 0
		RemoteEvents.UpdateFlight:FireServer({
			pitch         = inputPitch,
			roll          = inputRoll,
			yaw           = inputYaw,
			throttleDelta = inputThrottleDelta,
		})
	end
end)

-- ─── Boot ─────────────────────────────────────────────────────────────────────

LocalPlayer.CharacterAdded:Connect(function()
	-- Small delay to let character load
	task.wait(0.5)
	requestAirplane()
end)

if LocalPlayer.Character then
	task.wait(0.5)
	requestAirplane()
end

print("[AirplaneController] Loaded")
