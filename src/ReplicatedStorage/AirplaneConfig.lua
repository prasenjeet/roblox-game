-- Shared configuration for the airplane simulator

local AirplaneConfig = {
	-- Physics
	MaxThrust = 800,
	MinThrust = 0,
	ThrustAcceleration = 80,
	LiftCoefficient = 2.5,
	DragCoefficient = 0.08,
	RollSpeed = 55,
	PitchSpeed = 40,
	YawSpeed = 20,
	MaxSpeed = 350,
	StallSpeed = 40,
	Gravity = 196.2,

	-- Throttle
	ThrottleStep = 0.05,

	-- Spawn
	SpawnAltitude = 100,
	SpawnPosition = Vector3.new(0, 100, 0),

	-- Camera
	CameraDistance = 30,
	CameraHeight = 8,
	CameraLerpSpeed = 0.12,

	-- HUD update rate
	HUDUpdateInterval = 0.05,

	-- Airplane body dimensions (studs)
	Body = {
		Size = Vector3.new(14, 3, 5),
	},
	Wing = {
		Size = Vector3.new(4, 0.6, 20),
	},
	Tail = {
		Size = Vector3.new(3, 4, 1),
	},
	HorizontalStabilizer = {
		Size = Vector3.new(3, 0.5, 8),
	},
	Engine = {
		Size = Vector3.new(3, 3, 3),
	},
	Propeller = {
		Size = Vector3.new(0.5, 12, 0.5),
	},
}

return AirplaneConfig
