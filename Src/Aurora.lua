local camera = workspace.CurrentCamera

local polarLightsPart = Instance.new("Part")
polarLightsPart.Name = "polarLightsPart"
polarLightsPart.Transparency = 1
polarLightsPart.Anchored = true
polarLightsPart.CanCollide = false
polarLightsPart.CanQuery = false
polarLightsPart.CanTouch = false
polarLightsPart.Size = Vector3.new(1,1,1)
polarLightsPart.Orientation = Vector3.new(0, 0, -90)
polarLightsPart.Parent = workspace

local polarLightsEmitter = Instance.new("ParticleEmitter")
polarLightsEmitter.Name = "polarLightsEmitter"
polarLightsEmitter.Brightness = 0.3
polarLightsEmitter.LightEmission = 1
polarLightsEmitter.LightInfluence = 0.2
polarLightsEmitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
polarLightsEmitter.Size = NumberSequence.new(1400)
polarLightsEmitter.Squash = NumberSequence.new(2, 2)
polarLightsEmitter.Texture = "rbxassetid://110170832236629"
polarLightsEmitter.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.167, 1),
	NumberSequenceKeypoint.new(0.552, 0.2),
	NumberSequenceKeypoint.new(1, 1)
})
polarLightsEmitter.Lifetime = NumberRange.new(2, 4)
polarLightsEmitter.Rate = 230
polarLightsEmitter.Speed = NumberRange.new(10000)
polarLightsEmitter.SpreadAngle = Vector2.new(180, 0)
polarLightsEmitter.Drag = 9
polarLightsEmitter.Parent = polarLightsPart
polarLightsEmitter.Enabled = true

getgenv().AuroraModes = {
	Green = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(141,255,133)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(233,255,241)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(165,243,255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(108,255,120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(247,255,174))
	}),
	
	Pink = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 180)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 120, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 50, 150)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 0, 120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 220))
	}),
	
	Red = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 40, 50)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 20, 40)),
		ColorSequenceKeypoint.new(0.45,Color3.fromRGB(220, 10, 60)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 60, 90)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 30, 70))
	}),
	
	Blue = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(80, 230, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 180, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(60, 150, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 220, 255))
	}),
	
	Yellow = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 100)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 240, 140)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 180, 60)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 200, 80)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 250, 180))
	})
}

getgenv().SetAuroraMode = function(mode)
	if getgenv().AuroraModes[mode] then
		polarLightsEmitter.Color = getgenv().AuroraModes[mode]
	end
end

getgenv().SetAuroraMode("Red")

while task.wait(2) do	
	polarLightsPart.Position = camera.CFrame.Position + Vector3.new(0, -5, 0)
	polarLightsPart.Orientation = Vector3.new(0, 0, -90)
endend
