-- CLIENT GUI: Flight heads-up display (speed, altitude, throttle, attitude)
-- This is a LocalScript placed inside StarterGui > FlightHUD

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules      = ReplicatedStorage:WaitForChild("Modules", 10)
local RemoteEvents = require(Modules:WaitForChild("RemoteEvents", 10))

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Build HUD ────────────────────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightHUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local function makeFrame(name, size, pos, bg, alpha)
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = bg or Color3.fromRGB(0, 0, 0)
	f.BackgroundTransparency = alpha or 0.5
	f.BorderSizePixel = 0
	f.Parent = screenGui
	return f
end

local function makeLabel(name, parent, text, size, pos, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or Color3.fromRGB(0, 255, 100)
	l.TextScaled = true
	l.Font = Enum.Font.RobotoMono
	l.Parent = parent
	return l
end

-- Left panel – speed & altitude
local leftPanel = makeFrame("LeftPanel",
	UDim2.new(0, 200, 0, 160),
	UDim2.new(0, 16, 0.5, -80),
	Color3.fromRGB(10, 10, 30), 0.35)

makeLabel("Title", leftPanel, "FLIGHT DATA",
	UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0),
	Color3.fromRGB(150, 200, 255))

local speedLabel    = makeLabel("Speed",    leftPanel, "SPD:  0 u/s",
	UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 35))
local altLabel      = makeLabel("Altitude", leftPanel, "ALT:  0 u",
	UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 68))
local pitchLabel    = makeLabel("Pitch",    leftPanel, "PCH:  0°",
	UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 101))
local rollLabel     = makeLabel("Roll",     leftPanel, "ROL:  0°",
	UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 134))

-- Right panel – throttle bar
local rightPanel = makeFrame("RightPanel",
	UDim2.new(0, 60, 0, 180),
	UDim2.new(1, -76, 0.5, -90),
	Color3.fromRGB(10, 10, 30), 0.35)

makeLabel("ThrottleTitle", rightPanel, "THR",
	UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 0),
	Color3.fromRGB(150, 200, 255))

local throttleBarBg = Instance.new("Frame")
throttleBarBg.Size = UDim2.new(0.5, 0, 0, 130)
throttleBarBg.Position = UDim2.new(0.25, 0, 0, 28)
throttleBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
throttleBarBg.BorderSizePixel = 1
throttleBarBg.BorderColor3 = Color3.fromRGB(0, 200, 100)
throttleBarBg.Parent = rightPanel

local throttleBar = Instance.new("Frame")
throttleBar.Name = "ThrottleBar"
throttleBar.Size = UDim2.new(1, 0, 0, 0)     -- height driven by %
throttleBar.Position = UDim2.new(0, 0, 1, 0) -- anchored to bottom
throttleBar.AnchorPoint = Vector2.new(0, 1)
throttleBar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
throttleBar.BorderSizePixel = 0
throttleBar.Parent = throttleBarBg

local throttlePctLabel = makeLabel("ThrottlePct", rightPanel, "0%",
	UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 158),
	Color3.fromRGB(0, 255, 100))

-- Controls hint (bottom centre)
local hintFrame = makeFrame("HintFrame",
	UDim2.new(0, 400, 0, 50),
	UDim2.new(0.5, -200, 1, -66),
	Color3.fromRGB(0, 0, 0), 0.55)

makeLabel("Hint", hintFrame,
	"W/S: Pitch  |  A/D: Roll  |  Q/E: Yaw  |  Shift/Ctrl: Throttle",
	UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
	Color3.fromRGB(180, 180, 180))

-- ─── Update loop ──────────────────────────────────────────────────────────────

RemoteEvents.FlightData.OnClientEvent:Connect(function(data)
	speedLabel.Text  = string.format("SPD:  %.1f u/s", data.speed or 0)
	altLabel.Text    = string.format("ALT:  %.1f u",   data.altitude or 0)
	pitchLabel.Text  = string.format("PCH:  %.1f°",    data.pitch or 0)
	rollLabel.Text   = string.format("ROL:  %.1f°",    data.roll or 0)

	local thr = math.clamp((data.throttle or 0) / 100, 0, 1)
	throttleBar.Size = UDim2.new(1, 0, thr, 0)
	-- Colour shifts red → green with throttle
	throttleBar.BackgroundColor3 = Color3.fromRGB(
		math.floor((1 - thr) * 220),
		math.floor(thr * 220),
		60)
	throttlePctLabel.Text = string.format("%d%%", data.throttle or 0)
end)

print("[FlightHUD] Loaded")
