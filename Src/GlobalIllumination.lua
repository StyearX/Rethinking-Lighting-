task.wait(0.5)
local lights = {}
local TRASH = {}
local lumens = {}

local sundir = game.Lighting:GetSunDirection()
local gi = true
local intensity = 0.040
local suncolor = Color3.fromRGB(255,255,255)
local glow = true
local lglow = true
local polight = true
local splight = true
local sulight = true
local brightlimit = {Min = 0, Max = 10}
local rangelimit = {Min = 6, Max = 60}
local raymult = 3

game.Lighting.LightingChanged:Connect(function()
    sundir = game.Lighting:GetSunDirection()
end)

local function GetFace(Way, Cframe)
    if Way == Enum.NormalId.Back then return -Cframe.LookVector end
    if Way == Enum.NormalId.Front then return Cframe.LookVector end
    if Way == Enum.NormalId.Left then return -Cframe.RightVector end
    if Way == Enum.NormalId.Right then return Cframe.RightVector end
    if Way == Enum.NormalId.Top then return Cframe.UpVector end
    if Way == Enum.NormalId.Bottom then return -Cframe.UpVector end
end

local function CheckPart(part)
    return part:IsA("Part") and (part.Transparency > 0 or part.CastShadow == false)
end

function SendRayFromCamera(orig, direction, dt)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    local ray = game.Workspace:Raycast(orig, direction * 1000, params)
    
    if not ray then return end
    
    local col = nil
    local bright = 0
    local passes = true
    local islava = false
    
    if ray.Instance:IsA("Terrain") then
        col = game.Workspace.Terrain:GetMaterialColor(ray.Material)
        if ray.Material == Enum.Material.CrackedLava and lglow then
            passes = false
            bright = intensity
            islava = true
        end
    elseif ray.Instance:IsA("BasePart") then
        col = ray.Instance.Color
        if ray.Material == Enum.Material.Neon and glow then
            passes = false
            bright = intensity
        end
    end
    
    local islight = false
    local baselight = nil
    local mainlight = nil
    
    if passes and gi then
        local sunray = game.Workspace:Raycast(ray.Position + ray.Normal * 0.1, sundir * 1000, params)
        if not sunray then
            bright = intensity
            col = Color3.new(col.R * suncolor.R, col.G * suncolor.G, col.B * suncolor.B)
        else
            local check = CheckPart(sunray.Instance)
            if check then
                bright = intensity
                col = Color3.new(col.R * sunray.Instance.Color.R * suncolor.R, col.G * sunray.Instance.Color.G * suncolor.G, col.B * sunray.Instance.Color.B * suncolor.B)
            end
        end
        
        for _, light in lights do
            if light and light.Parent then
                local isValidType = (light:IsA("PointLight") and polight) or (light:IsA("SpotLight") and splight) or (light:IsA("SurfaceLight") and sulight)
                if isValidType and light.Enabled then
                    local b = light.Parent
                    if b:IsA("Attachment") then
                        b = b.Parent.Parent
                    end
                    
                    local pos = nil
                    local cf = nil
                    local pass = false
                    
                    if b:IsA("BasePart") then
                        pass = true
                        pos = b.Position
                        cf = b.CFrame
                    elseif b:IsA("Attachment") then
                        pass = true
                        pos = b.WorldPosition
                        cf = b.WorldCFrame
                    end
                    
                    local mag = (pos - ray.Position).Magnitude
                    if mag <= light.Range and pass then
                        local checked = true
                        
                        if light.Shadows then
                            checked = false
                            local shadowRay = game.Workspace:Raycast(ray.Position + ray.Normal * 0.1, (pos - (ray.Position + ray.Normal * 0.1)) * 1.1, params)
                            if shadowRay and shadowRay.Instance == b then
                                checked = true
                            end
                        end
                        
                        if checked then
                            if light:IsA("SpotLight") then
                                checked = false
                                local spotlightToPoint = (ray.Position - pos).Unit
                                local dir = cf.LookVector
                                local faceMap = {Front = cf.LookVector, Back = -cf.LookVector, Right = cf.RightVector, Left = -cf.RightVector, Top = cf.UpVector, Bottom = -cf.UpVector}
                                dir = faceMap[light.Face] or cf.LookVector
                                local dotproduct = spotlightToPoint:Dot(dir)
                                local requireddot = (light.Angle / 2) / 90
                                if dotproduct >= requireddot then
                                    checked = true
                                end
                            elseif light:IsA("SurfaceLight") then
                                checked = false
                                local cam = Instance.new("Camera")
                                cam.CameraType = Enum.CameraType.Scriptable
                                cam.FieldOfView = light.Angle
                                cam.CFrame = CFrame.new(pos)
                                local dir = GetFace(light.Face, cam.CFrame)
                                cam.CFrame = CFrame.new(pos, pos + dir)
                                local _, onScreen = cam:WorldToScreenPoint(ray.Position)
                                if onScreen then
                                    checked = true
                                end
                                cam:Destroy()
                            end
                            
                            if checked then
                                islight = true
                                mainlight = light
                                baselight = b
                                col = Color3.new(col.R * light.Color.R, col.G * light.Color.G, col.B * light.Color.B)
                                if bright == 0 then
                                    bright = intensity * light.Brightness
                                else
                                    bright = bright * light.Brightness
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if ray.Instance.Transparency >= 1 then
        bright = 0
    end
    
    if bright > 0 then
        bright = bright - ray.Distance / 10000
        local pointLight = Instance.new("PointLight")
        local attach = Instance.new("Attachment")
        
        if islight and baselight then
            attach.Parent = baselight
        else
            attach.Parent = ray.Instance
        end
        
        bright = math.clamp(bright, brightlimit.Min, brightlimit.Max)
        attach.WorldPosition = ray.Position + ray.Normal * 0.1
        pointLight:AddTag("DontCheck")
        pointLight.Parent = attach
        pointLight.Shadows = false
        pointLight.Color = col
        pointLight.Enabled = true
        pointLight.Brightness = bright
        pointLight.Range = math.clamp(ray.Distance / 3, rangelimit.Min, rangelimit.Max)
        
        if islava then
            local emberchance = math.random(1, 10)
            if emberchance == 1 then
                local ember = Instance.new("ParticleEmitter")
                ember.Texture = "rbxassetid://13015957526"
                ember.Rate = 1
                ember.Lifetime = NumberRange.new(0.5)
                ember.SpreadAngle = Vector2.new(360, 360)
                ember.VelocityInheritance = 0
                ember.Speed = NumberRange.new(2)
                ember.Enabled = true
                ember.Color = ColorSequence.new(col)
                ember.Parent = attach
                ember:Emit(1)
                task.delay(0.5, function() ember:Destroy() end)
            end
        end
        
        table.insert(TRASH, attach)
        
        local data = {
            Light = pointLight,
            Attachment = attach,
            BasePosition = attach.WorldPosition,
            BaseBrightness = pointLight.Brightness,
            BaseLight = mainlight,
            Events = {}
        }
        
        local function updateData()
            if not data or not data.Light or not data.Attachment then return end
            if data.BaseLight and data.BaseLight.Enabled == false then
                data.Light.Brightness = 0
            elseif data.BaseLight then
                local dist = (data.Attachment.WorldPosition - data.BasePosition).Magnitude
                local newBright = ((data.BaseLight.Range - dist) / data.BaseLight.Range) * data.BaseBrightness * data.BaseLight.Brightness
                if data.Light then data.Light.Brightness = newBright end
            else
                local dist = (data.Attachment.WorldPosition - data.BasePosition).Magnitude
                local newBright = ((data.Light.Range - dist) / data.Light.Range) * data.BaseBrightness
                if data.Light then data.Light.Brightness = newBright end
            end
        end
        
        data.Events[1] = attach:GetPropertyChangedSignal("WorldCFrame"):Connect(updateData)
        if mainlight then
            data.Events[2] = mainlight:GetPropertyChangedSignal("Enabled"):Connect(updateData)
            data.Events[3] = mainlight:GetPropertyChangedSignal("Brightness"):Connect(updateData)
        end
        
        table.insert(lumens, data)
        
        task.delay(0.05 / dt, function()
            table.remove(TRASH, table.find(TRASH, attach))
            if data and data.Events then
                for _, ev in pairs(data.Events) do
                    if ev and ev.Disconnect then ev:Disconnect() end
                end
            end
            local idx = table.find(lumens, data)
            if idx then table.remove(lumens, idx) end
            if attach then attach:Destroy() end
        end)
    end
end

local function RemoveLight(light)
    local idx = table.find(lights, light)
    if idx then table.remove(lights, idx) end
end

local function CheckAndAddLight(light)
    if (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) and not light:HasTag("DontCheck") then
        table.insert(lights, light)
        
        local ev1
        local ev2
        ev1 = light.Destroying:Connect(function()
            RemoveLight(light)
            if ev1 then ev1:Disconnect() end
        end)
        
        ev2 = light:GetPropertyChangedSignal("Parent"):Connect(function()
            if not light:FindFirstAncestorOfClass("Workspace") then
                RemoveLight(light)
                if ev2 then ev2:Disconnect() end
            end
        end)
    end
end

for _, light in game.Workspace:GetDescendants() do
    CheckAndAddLight(light)
end

game.Workspace.DescendantAdded:Connect(CheckAndAddLight)

local toggle = false

game:GetService("RunService").RenderStepped:Connect(function(dt)
    local cam = game.Workspace.CurrentCamera
    if cam and (gi or glow or lglow) then
        toggle = not toggle
        if toggle then
            local numRays = math.floor(raymult / dt / 2)
            for i = 1, numRays do
                local x = math.random(0, cam.ViewportSize.X)
                local y = math.random(0, cam.ViewportSize.Y)
                local ray = cam:ViewportPointToRay(x, y, 1000)
                SendRayFromCamera(cam.CFrame.Position, ray.Direction.Unit, dt * raymult)
            end
        end
    end
end)
