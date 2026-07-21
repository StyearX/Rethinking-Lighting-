local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local VolumetricClouds = Instance.new("Model")
VolumetricClouds.Name = "VolumetricClouds"
VolumetricClouds.Parent = Workspace

local Textures = {"rbxassetid://5192923984", "rbxassetid://7215671178"}
local Positions = {
	{-1,235,-24},
	{-1,240,-24},
	{-1,245,-24},
	{-1,250,-24},
	{-1,255,-24},
	{-1,260,-24},
	{-1,265,-24},
	{-1,270,-24},
	{-1,275,-24},
	{-1,280,-24},
	{-1,285,-24},
	{-1,290,-24},
	{-1,295,-24},
	{-1,300,-24},
	{-1,305,-24},
	{-1,310,-24},
	{-1,315,-24},
	{-1,320,-24},
	{-1,325,-24},
	{-1,330,-24},
	{-1,335,-24},
	{-1,340,-24},
	{-1,345,-24},
	{-1,350,-24},
	{-846,235,-901.5},
	{-846,240,-901.5},
	{-846,245,-901.5},
	{-846,250,-901.5},
	{-846,255,-901.5},
	{-846,260,-901.5},
	{-846,265,-901.5},
	{-846,270,-901.5},
	{-846,275,-901.5},
	{-846,280,-901.5},
	{-846,285,-901.5},
	{-846,290,-901.5},
	{-846,295,-901.5},
	{-846,300,-901.5},
	{-846,305,-901.5},
	{-846,310,-901.5},
	{-846,315,-901.5},
	{-846,320,-901.5},
	{-846,325,-901.5},
	{-846,330,-901.5},
	{-846,335,-901.5},
	{-846,340,-901.5},
	{-846,345,-901.5},
	{-846,350,-901.5}
}

for i, pos in ipairs(Positions) do
	local Part = Instance.new("Part")
	Part.Name = "Clouds" .. i
	Part.Parent = VolumetricClouds
	Part.Size = Vector3.new(50,16,50)
	Part.CFrame = CFrame.new(pos[1], pos[2], pos[3]) * CFrame.Angles(0, math.rad(180), 0)
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanQuery = true
	Part.CanTouch = true
	Part.CastShadow = true
	Part.Locked = true
	Part.Transparency = 1
	Part.Material = Enum.Material.Neon
	Part.Color = Color3.fromRGB(255,252,252)
	Part.Shape = Enum.PartType.Block
	Part.BrickColor = BrickColor.new("Institutional white")
	
	local Att0 = Instance.new("Attachment")
	Att0.Name = "Attachment0"
	Att0.Parent = Part
	Att0.CFrame = CFrame.new(10024,0,0) * CFrame.Angles(math.rad(90), 0, 0)
	
	local Att1 = Instance.new("Attachment")
	Att1.Name = "Attachment1"
	Att1.Parent = Part
	Att1.CFrame = CFrame.new(-10024,0,0) * CFrame.Angles(math.rad(90), 0, 0)
	
	local Beam = Instance.new("Beam")
	Beam.Parent = Part
	Beam.Attachment0 = Att0
	Beam.Attachment1 = Att1
	Beam.Width0 = 20048
	Beam.Width1 = 20048
	Beam.Segments = 1
	Beam.FaceCamera = false
	Beam.Texture = (i == 1 or i == 25) and Textures[1] or Textures[2]
	Beam.TextureLength = 1
	Beam.TextureMode = Enum.TextureMode.Stretch
	Beam.TextureSpeed = 0.001
	Beam.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
	Beam.Transparency = NumberSequence.new(0.6)
	Beam.Brightness = 1
	Beam.LightEmission = 0
	Beam.LightInfluence = 1
	Beam.ZOffset = 0
	Beam.Enabled = true
end

local DayColor = Color3.fromRGB(255,255,255)
local NightColor = Color3.fromRGB(90,90,100)

local function GetDaylightFactor()
	local sunDirectionY = Lighting:GetSunDirection().Y
	local factor = (sunDirectionY + 0.15) / 0.3
	return math.clamp(factor, 0, 1)
end

local function UpdateCloudsColor()
	local daylightFactor = GetDaylightFactor()
	local currentColor = DayColor:Lerp(NightColor, 1 - daylightFactor)
	local currentColorSequence = ColorSequence.new(currentColor)

	for _, cloudPart in ipairs(VolumetricClouds:GetChildren()) do
		local beam = cloudPart:FindFirstChild("Beam")
		if beam then
			beam.Color = currentColorSequence
		end
	end
end

UpdateCloudsColor()
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(UpdateCloudsColor)
Lighting:GetPropertyChangedSignal("Brightness"):Connect(UpdateCloudsColor)
