-- Creates and returns all RemoteEvents/RemoteFunctions used by the game.
-- Call this from both server (to create) and client (to retrieve).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = parent
	return obj
end

local Events = {}

local function setup()
	local folder = getOrCreate(ReplicatedStorage, "Folder", "AirplaneEvents")

	Events.RequestAirplane   = getOrCreate(folder, "RemoteFunction", "RequestAirplane")
	Events.UpdateFlight      = getOrCreate(folder, "RemoteEvent",    "UpdateFlight")
	Events.AirplaneDestroyed = getOrCreate(folder, "RemoteEvent",    "AirplaneDestroyed")
	Events.FlightData        = getOrCreate(folder, "RemoteEvent",    "FlightData")
end

setup()

return Events
