local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Size = UDim2.new(1, 0, 1, 0)
viewportFrame.BackgroundTransparency = 1
viewportFrame.Parent = screenGui

local camera = Instance.new("Camera")
camera.Parent = viewportFrame
viewportFrame.CurrentCamera = camera

local glyphParts = Instance.new("Folder")
glyphParts.Name = "GlyphParts"
glyphParts.Parent = viewportFrame

local function createMeshPart(letterName, meshId, size, xPos)
	local meshPart = Instance.new("MeshPart")
	meshPart.Name = letterName
	meshPart.MeshId = meshId
	meshPart.Size = size
	meshPart.CFrame = CFrame.new(xPos, 0.45, -5) * CFrame.Angles(0, math.rad(180), 0)
	meshPart.Color = Color3.fromRGB(255, 245, 170)
	meshPart.Material = Enum.Material.Neon
	meshPart.Reflectance = 0.6
	meshPart.Transparency = 0
	meshPart.CastShadow = false
	meshPart.Anchored = true
	meshPart.CanCollide = false
	meshPart.Parent = glyphParts
	return meshPart
end

local letters = {
	{char = "R", id = "rbxassetid://3292265073", size = Vector3.new(1.05, 1.05, 0.1), x = -7.2},
	{char = "E", id = "rbxassetid://3292269527", size = Vector3.new(0.95, 1.05, 0.1),   x = -5.9},
	{char = "T", id = "rbxassetid://3292264954", size = Vector3.new(1.02, 1.05, 0.1), x = -4.85},
	{char = "H", id = "rbxassetid://3292265759", size = Vector3.new(1.12, 1.05, 0.1), x = -3.65},
	{char = "I", id = "rbxassetid://3292265685", size = Vector3.new(0.55, 1.05, 0.1), x = -2.55},
	{char = "N", id = "rbxassetid://3292265365", size = Vector3.new(1.25, 1.05, 0.1), x = -1.45},
	{char = "K", id = "rbxassetid://3292265559", size = Vector3.new(1.08, 1.05, 0.1), x = 0.0},
	{char = "I", id = "rbxassetid://3292265685", size = Vector3.new(0.55, 1.05, 0.1), x = 1.35},
	{char = "N", id = "rbxassetid://3292265365", size = Vector3.new(1.25, 1.05, 0.1), x = 2.4},
	{char = "G", id = "rbxassetid://3292265823", size = Vector3.new(1.05, 1.08, 0.1), x = 4.0},
	{char = "L", id = "rbxassetid://3292265484", size = Vector3.new(0.85, 1.05, 0.1), x = 7.5},
	{char = "I", id = "rbxassetid://3292265685", size = Vector3.new(0.55, 1.05, 0.1), x = 8.65},
	{char = "G", id = "rbxassetid://3292265823", size = Vector3.new(1.05, 1.08, 0.1), x = 9.4},
	{char = "H", id = "rbxassetid://3292265759", size = Vector3.new(1.12, 1.05, 0.1), x = 10.8},
	{char = "T", id = "rbxassetid://3292264954", size = Vector3.new(1.02, 1.05, 0.1), x = 12.2},
	{char = "I", id = "rbxassetid://3292265685", size = Vector3.new(0.55, 1.05, 0.1), x = 13.45},
	{char = "N", id = "rbxassetid://3292265365", size = Vector3.new(1.25, 1.05, 0.1), x = 14.4},
	{char = "G", id = "rbxassetid://3292265823", size = Vector3.new(1.05, 1.08, 0.1), x = 16.0},
}

for _, letter in ipairs(letters) do
	createMeshPart(letter.char, letter.id, letter.size, letter.x)
end

local function updateCamera()
	local viewportSize = viewportFrame.AbsoluteSize
	local aspect = viewportSize.X / viewportSize.Y
	
	local distance = aspect < 1.6 and 13.5 or 11.5
	
	camera.CFrame = CFrame.new(
		Vector3.new(4.5, 3.2, distance), 
		Vector3.new(4.8, 0.7, -5)
	)
end

viewportFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCamera)
updateCamera()

local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local offset = Vector3.new(0, 0, 0)

local connection = runService.RenderStepped:Connect(function()
	local delta = userInputService:GetMouseDelta()
	offset = offset + Vector3.new(delta.X * 0.0038, -delta.Y * 0.0038, 0)
	offset = Vector3.new(math.clamp(offset.X, -4.5, 4.5), math.clamp(offset.Y, -2, 2), 0)
	
	local camPos = Vector3.new(4.5 + offset.X * 0.8, 3.2 + offset.Y * 0.7, 12)
	local lookAt = Vector3.new(4.8 + offset.X * 0.4, 0.7, -5)
	
	camera.CFrame = CFrame.new(camPos, lookAt)
end)

task.wait(5)

local function fadeOut()
	local t = 0
	while t < 1 do
		t += 0.055
		for _, part in ipairs(glyphParts:GetChildren()) do
			if part:IsA("MeshPart") then
				part.Transparency = t
			end
		end
		task.wait(0.028)
	end
	screenGui:Destroy()
	connection:Disconnect()
end

fadeOut()
