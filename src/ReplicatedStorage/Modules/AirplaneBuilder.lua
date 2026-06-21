-- Builds an airplane model in the Workspace from primitives.
-- Returns the model root with a PrimaryPart set to the fuselage.

local AirplaneConfig = require(script.Parent.Parent.AirplaneConfig)

local AirplaneBuilder = {}

local function makeWeld(part, root)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = root
end

local function addPart(model, root, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.BrickColor = BrickColor.new(color or "Medium stone grey")
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = false
	part.CanCollide = false
	part.Parent = model
	if root then makeWeld(part, root) end
	return part
end

function AirplaneBuilder.Build(owner)
	local model = Instance.new("Model")
	model.Name = owner.Name .. "_Airplane"

	-- Fuselage (primary part)
	local cfg = AirplaneConfig
	local fuselage = addPart(model, nil, "Fuselage",
		cfg.Body.Size,
		CFrame.new(0, 0, 0),
		"Navy blue",
		Enum.Material.SmoothPlastic)
	fuselage.CanCollide = true
	model.PrimaryPart = fuselage

	-- Left wing
	addPart(model, fuselage, "WingLeft",
		cfg.Wing.Size,
		CFrame.new(0, -0.5, -cfg.Wing.Size.Z / 2 - 0.5) * CFrame.Angles(0, 0, math.rad(-4)),
		"Bright blue")

	-- Right wing
	addPart(model, fuselage, "WingRight",
		cfg.Wing.Size,
		CFrame.new(0, -0.5,  cfg.Wing.Size.Z / 2 + 0.5) * CFrame.Angles(0, 0, math.rad(4)),
		"Bright blue")

	-- Vertical tail
	addPart(model, fuselage, "VerticalTail",
		cfg.Tail.Size,
		CFrame.new(-cfg.Body.Size.X / 2 + 1.5, cfg.Tail.Size.Y / 2, 0),
		"Bright blue")

	-- Horizontal stabilizer left
	addPart(model, fuselage, "HStabLeft",
		cfg.HorizontalStabilizer.Size,
		CFrame.new(-cfg.Body.Size.X / 2 + 1.5, 0.5, -cfg.HorizontalStabilizer.Size.Z / 2),
		"Bright blue")

	-- Horizontal stabilizer right
	addPart(model, fuselage, "HStabRight",
		cfg.HorizontalStabilizer.Size,
		CFrame.new(-cfg.Body.Size.X / 2 + 1.5, 0.5,  cfg.HorizontalStabilizer.Size.Z / 2),
		"Bright blue")

	-- Engine nacelle (front)
	addPart(model, fuselage, "Engine",
		cfg.Engine.Size,
		CFrame.new(cfg.Body.Size.X / 2 + 1.5, 0, 0),
		"Dark stone grey",
		Enum.Material.Metal)

	-- Propeller
	local prop = addPart(model, fuselage, "Propeller",
		cfg.Propeller.Size,
		CFrame.new(cfg.Body.Size.X / 2 + 3.5, 0, 0) * CFrame.Angles(0, 0, math.rad(90)),
		"Dark stone grey",
		Enum.Material.Metal)
	prop.CanCollide = false

	-- Cockpit glass
	local cockpit = addPart(model, fuselage, "Cockpit",
		Vector3.new(4, 2.5, 3),
		CFrame.new(cfg.Body.Size.X / 2 - 3, 2, 0),
		"Institutional white",
		Enum.Material.Glass)
	cockpit.Transparency = 0.4
	cockpit.CanCollide = false

	-- BodyMover parts (applied to fuselage at runtime by the server)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "BodyVelocity"
	bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = fuselage

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.Name = "BodyAngularVelocity"
	bodyAngularVelocity.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyAngularVelocity.AngularVelocity = Vector3.zero
	bodyAngularVelocity.Parent = fuselage

	-- Attribute: owner
	model:SetAttribute("Owner", owner.UserId)

	model.Parent = workspace
	return model
end

function AirplaneBuilder.Destroy(model)
	if model and model.Parent then
		model:Destroy()
	end
end

return AirplaneBuilder
