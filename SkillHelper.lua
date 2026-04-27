local DilLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/DilUI.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = {
        Enabled = false,
        ShowFOV = false,
        Radius = 150,
        Smoothness = 0.5,
        TargetPart = "Head"
    },
    Visuals = {
        ESPEnabled = false,
        Tracers = false,
        RainbowMode = false,
        ESPColor = Color3.fromRGB(255, 0, 0)
    },
    HVH = {
        Spinbot = false,
        SpinSpeed = 25,
        AutoJump = false
    }
}

local TracersMap = {}

local Window = DilLib:MakeWindow({
    Name = "DIL.AIM",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "HVH_Config",
    IntroEnabled = true,
    IntroText = "DIL.AIM", 
    KeyToOpenWindow = "K"
})

local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
local AimTab = Window:MakeTab({ Name = "Aimbot", Icon = "rbxassetid://4483345998" })
local VisTab = Window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" })

local HvhSection = MainTab:AddSection({ Name = "HVH" })

HvhSection:AddToggle({
    Name = "Anti-AIM (Spinbot)",
    Default = false,
    Callback = function(Value) Settings.HVH.Spinbot = Value end
})

HvhSection:AddSlider({
    Name = "Spin Speed",
    Min = 5, Max = 100, Default = 25, Increment = 1, ValueName = "Speed",
    Callback = function(Value) Settings.HVH.SpinSpeed = Value end
})

HvhSection:AddToggle({
    Name = "Auto Jump",
    Default = false,
    Callback = function(Value) Settings.HVH.AutoJump = Value end
})

local AimSection = AimTab:AddSection({ Name = "Combat Settings" })

AimSection:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value) Settings.Aimbot.Enabled = Value end
})

AimSection:AddToggle({
    Name = "FOV Circle",
    Default = false,
    Callback = function(Value) Settings.Aimbot.ShowFOV = Value end
})

AimSection:AddSlider({
    Name = "FOV Radius",
    Min = 10, Max = 600, Default = 150, Increment = 5, ValueName = "px",
    Callback = function(Value) Settings.Aimbot.Radius = Value end
})

AimSection:AddSlider({
    Name = "Aim Smoothness",
    Min = 0.01, Max = 1, Default = 0.5, Increment = 0.05, ValueName = " (1=Instant)",
    Callback = function(Value) Settings.Aimbot.Smoothness = Value end
})

AimSection:AddDropdown({
    Name = "Target Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Callback = function(Value) Settings.Aimbot.TargetPart = Value end
})

local VisSection = VisTab:AddSection({ Name = "ESP & Effects" })

VisSection:AddToggle({
    Name = "Enable ESP (WallHack)",
    Default = false,
    Callback = function(Value)
        Settings.Visuals.ESPEnabled = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("DIL_Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end
})

VisSection:AddToggle({
    Name = "Enable Tracers",
    Default = false,
    Callback = function(Value) Settings.Visuals.Tracers = Value end
})

VisSection:AddToggle({
    Name = "Rainbow Mode (RGB Animation)",
    Default = false,
    Callback = function(Value) Settings.Visuals.RainbowMode = Value end
})

VisSection:AddColorpicker({
    Name = "Visuals Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) Settings.Visuals.ESPColor = Value end
})

local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64 

local function UpdateEffects()
    local RainbowColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    local CurrentColor = Settings.Visuals.RainbowMode and RainbowColor or Settings.Visuals.ESPColor

    if Settings.Aimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.Aimbot.Radius
        FOVCircle.Color = CurrentColor
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        FOVCircle.Visible = false
    end

    return CurrentColor
end

local function GetClosestPlayerToCenter()
    local ClosestTarget = nil
    local ShortestDistance = Settings.Aimbot.Radius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            local TargetPart = Player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if TargetPart then
                local ScreenPoint, IsVisibleOnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                if IsVisibleOnScreen then
                    local Distance = (Center - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                    if Distance < ShortestDistance then
                        ShortestDistance = Distance
                        ClosestTarget = TargetPart
                    end
                end
            end
        end
    end
    return ClosestTarget
end

local function UpdateVisuals(CurrentColor)
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Char = Player.Character
            local Hum = Char:FindFirstChild("Humanoid")
            local Root = Char:FindFirstChild("HumanoidRootPart")

            if Hum and Hum.Health > 0 and Root then
                if Settings.Visuals.ESPEnabled then
                    local Highlight = Char:FindFirstChild("DIL_Highlight")
                    if not Highlight then
                        Highlight = Instance.new("Highlight")
                        Highlight.Name = "DIL_Highlight"
                        Highlight.Parent = Char
                    end
                    Highlight.Adornee = Char
                    Highlight.FillColor = CurrentColor
                    Highlight.OutlineColor = Color3.new(1, 1, 1)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                else
                    local h = Char:FindFirstChild("DIL_Highlight")
                    if h then h:Destroy() end
                end

                if not TracersMap[Player] then
                    TracersMap[Player] = Drawing.new("Line")
                    TracersMap[Player].Thickness = 1.5
                end
                
                local Line = TracersMap[Player]
                if Settings.Visuals.Tracers then
                    local Vector, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                    if OnScreen then
                        Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Line.To = Vector2.new(Vector.X, Vector.Y)
                        Line.Color = CurrentColor
                        Line.Visible = true
                    else
                        Line.Visible = false
                    end
                else
                    Line.Visible = false
                end
            else
                local h = Char:FindFirstChild("DIL_Highlight")
                if h then h:Destroy() end
                if TracersMap[Player] then TracersMap[Player].Visible = false end
            end
        end
    end
end

local function UpdateHVH()
    local Character = LocalPlayer.Character
    if not Character then return end
    if Settings.HVH.Spinbot and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Settings.HVH.SpinSpeed), 0)
    end
    if Settings.HVH.AutoJump and Character:FindFirstChild("Humanoid") then
        if Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            Character.Humanoid.Jump = true
        end
    end
end

RunService.RenderStepped:Connect(function()
    local ActiveColor = UpdateEffects()
    UpdateVisuals(ActiveColor)
    UpdateHVH()
    if Settings.Aimbot.Enabled then
        local Target = GetClosestPlayerToCenter()
        if Target then
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, Settings.Aimbot.Smoothness)
        end
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    if TracersMap[Player] then
        TracersMap[Player]:Remove()
        TracersMap[Player] = nil
    end
end)

DilLib:Init()
