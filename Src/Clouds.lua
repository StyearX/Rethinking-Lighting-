local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TEXTURE_CUMULUS = "rbxassetid://6812398408"
local TEXTURE_STRATUS = "rbxassetid://6816457996"

local function CreateCloudTemplate(name, textureId)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(3.572, 0.143, 3.572)
    part.CFrame = CFrame.new(392.629, 534, -405.891) * CFrame.Angles(0, math.rad(180), 0)
    part.Color = Color3.fromRGB(255, 255, 255)
    part.Material = Enum.Material.Plastic
    part.Reflectance = 0
    part.Transparency = 1
    part.CanCollide = false
    part.CanTouch = false
    part.Anchored = true
    part.Locked = true
    part.CastShadow = true
    
    local mesh = Instance.new("BlockMesh")
    mesh.Parent = part
    mesh.Scale = Vector3.new(3000, 1, 3000)
    mesh.Offset = Vector3.new(0, 0, 0)
    
    local shadow = Instance.new("Decal")
    shadow.Parent = part
    shadow.Name = "Shadow"
    shadow.Face = Enum.NormalId.Bottom
    shadow.Texture = textureId
    shadow.Color3 = Color3.fromRGB(255, 255, 255)
    shadow.Transparency = 0.73
    
    local tex1 = Instance.new("Texture")
    tex1.Parent = part
    tex1.Name = "Texture1"
    tex1.Face = Enum.NormalId.Bottom
    tex1.Texture = textureId
    tex1.Color3 = Color3.fromRGB(255, 255, 255)
    tex1.Transparency = 1
    
    local tex2 = Instance.new("Texture")
    tex2.Parent = part
    tex2.Name = "Texture2"
    tex2.Face = Enum.NormalId.Top
    tex2.Texture = textureId
    tex2.Color3 = Color3.fromRGB(255, 255, 255)
    tex2.Transparency = 1
    
    return part
end

local CumulusTemplate = CreateCloudTemplate("CumulusCloud", TEXTURE_CUMULUS)
local StratusTemplate = CreateCloudTemplate("StratusCloud", TEXTURE_STRATUS)

CumulusTemplate.Parent = workspace
StratusTemplate.Parent = workspace

local CloudSystem = {}
CloudSystem.__index = CloudSystem

function CloudSystem.new(config)
    local self = setmetatable({}, CloudSystem)
    self.Tallness = config.Tallness or 40
    self.Offset = config.Offset or 0
    self.Density = config.Density or 0.2
    self.Speed = config.Speed or 5
    self.Height = config.Height or 534
    self.Size = config.Size or 3.572
    self.ShadowCast = config.ShadowCast == nil and true or config.ShadowCast
    self.CloudType = config.CloudType or "Cumulus"
    self.CloudsList = {}
    return self
end

function CloudSystem:Start()
    local template = self.CloudType == "Cumulus" and CumulusTemplate or StratusTemplate
    spawn(function()
        local lastCloud = template
        local DarknessVal = 100
        local RealRandom = Random.new()
        local startPos = Vector3.new(392.629, self.Height, -405.891)
        lastCloud.Position = startPos
        
        for i = 1, self.Tallness do
            local cl = lastCloud:Clone()
            local ranX = math.random(-self.Offset, self.Offset)
            local ranZ = math.random(-self.Offset, self.Offset)
            cl.Parent = workspace
            cl.Anchored = true
            cl.CanCollide = false
            cl.Position = lastCloud.Position + Vector3.new(ranX, 5, ranZ)
            
            local tex1 = cl:FindFirstChild("Texture1")
            local tex2 = cl:FindFirstChild("Texture2")
            local shadow = cl:FindFirstChild("Shadow")
            
            if tex1 then
                tex1.Transparency = 1 - self.Density
                tex1.Color3 = Color3.fromRGB(DarknessVal, DarknessVal, DarknessVal)
            end
            if tex2 then
                tex2.Transparency = 1 - self.Density
                tex2.Color3 = Color3.fromRGB(DarknessVal, DarknessVal, DarknessVal)
            end
            if shadow then
                shadow.Color3 = Color3.fromRGB(DarknessVal, DarknessVal, DarknessVal)
            end
            
            cl.CastShadow = self.ShadowCast
            
            if self.Size == 3.572 then
                cl.Size = Vector3.new(RealRandom:NextNumber(2.9, 3), 0.143, RealRandom:NextNumber(2.9, 3))
            else
                cl.Size = Vector3.new(RealRandom:NextNumber(2.9, self.Size), 0.143, RealRandom:NextNumber(2.9, self.Size))
            end
            
            local mesh = cl:FindFirstChild("Mesh")
            if mesh then
                mesh.Scale = Vector3.new(cl.Size.X * 840, 1, cl.Size.Z * 840)
            end
            
            DarknessVal = math.min(DarknessVal + 10, 255)
            lastCloud = cl
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if cl and cl.Parent then
                    cl.CFrame = cl.CFrame * CFrame.new(0, 0, self.Speed / 10)
                    if cl.Position.Z > 1000 then
                        cl.Position = Vector3.new(cl.Position.X, cl.Position.Y, -800)
                    end
                else
                    if connection then connection:Disconnect() end
                end
            end)
            
            table.insert(self.CloudsList, {cloud = cl, connection = connection})
        end
    end)
end

function CloudSystem:Stop()
    for _, data in ipairs(self.CloudsList) do
        if data.connection then data.connection:Disconnect() end
        if data.cloud then data.cloud:Destroy() end
    end
    self.CloudsList = {}
end

local Clouds = CloudSystem.new({
    Tallness = 30,
    Offset = 0,
    Density = 0.4,
    Speed = 8,
    Height = 534,
    Size = 3.572,
    ShadowCast = true,
    CloudType = "Cumulus"
})

Clouds:Start()
