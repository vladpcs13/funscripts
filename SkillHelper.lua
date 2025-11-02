local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Cheats for My Roblox Game",
   LoadingTitle = "Loading Cheats Menu",
   LoadingSubtitle = "For Roblox Studio Game",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MyGameCheats",
      FileName = "config"
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main Cheats", 4483362458)

MainTab:CreateSection("Aimbot Controls")

local AimbotEnabled = false
local AimbotSensitivity = 1
local FOV = 100
local FOVColor = Color3.fromRGB(255, 0, 0)
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local fovCircleGui = Instance.new("ScreenGui")
fovCircleGui.Parent = game.CoreGui
fovCircleGui.IgnoreGuiInset = true

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, FOV*2, 0, FOV*2)
fovCircle.Position = UDim2.new(0.5, -FOV, 0.5, -FOV)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = fovCircleGui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(1, 0)
uicorner.Parent = fovCircle

local uistroke = Instance.new("UIStroke")
uistroke.Thickness = 2
uistroke.Color = FOVColor
uistroke.Transparency = 0.5
uistroke.Parent = fovCircle

local function UpdateFOVCircle(radius, color)
   fovCircle.Size = UDim2.new(0, radius*2, 0, radius*2)
   fovCircle.Position = UDim2.new(0.5, -radius, 0.5, -radius)
   uistroke.Color = color or uistroke.Color
end

local function GetNearestTarget()
   local nearest = nil
   local minDist = FOV
   local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
   
   for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
         local head = player.Character:FindFirstChild("Head")
         if head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
               local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
               if dist < minDist then
                  minDist = dist
                  nearest = head
               end
            end
         end
      end
   end
   
   return nearest
end

local AimbotConnection

local AimbotToggle = MainTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotEnabled = Value
      fovCircle.Visible = Value
      if Value then
         AimbotConnection = RunService.RenderStepped:Connect(function(delta)
            if AimbotEnabled then
               local target = GetNearestTarget()
               if target then
                  local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
                  Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSensitivity * delta)
               end
            end
         end)
      else
         if AimbotConnection then
            AimbotConnection:Disconnect()
         end
      end
   end,
})

MainTab:CreateSlider({
   Name = "Aimbot Sensitivity",
   Range = {0.1, 25},
   Increment = 0.1,
   Suffix = "x",
   CurrentValue = 1,
   Flag = "AimbotSensitivity",
   Callback = function(Value)
      AimbotSensitivity = Value
   end,
})

MainTab:CreateSlider({
   Name = "Aimbot FOV Radius",
   Range = {50, 500},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "AimbotFOV",
   Callback = function(Value)
      FOV = Value
      UpdateFOVCircle(Value)
   end,
})

MainTab:CreateSection("WallHack Controls")

local WallHackEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPInstances = {}

local function UpdateESPColor(color)
   for _, inst in ipairs(ESPInstances) do
      if inst:IsA("Highlight") then
         inst.FillColor = color
      end
   end
end

local function CreateESP(player)
   if player.Character then
      local highlight = Instance.new("Highlight")
      highlight.Name = "ESPHighlight"
      highlight.FillTransparency = 0.5
      highlight.OutlineTransparency = 0
      highlight.FillColor = ESPColor
      highlight.Parent = player.Character
      table.insert(ESPInstances, highlight)
      
      local billboard = Instance.new("BillboardGui")
      billboard.Name = "ESPBillboard"
      billboard.Adornee = player.Character:FindFirstChild("Head")
      billboard.Size = UDim2.new(0, 100, 0, 50)
      billboard.StudsOffset = Vector3.new(0, 3, 0)
      billboard.AlwaysOnTop = true
      
      local nameLabel = Instance.new("TextLabel")
      nameLabel.Text = player.Name
      nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
      nameLabel.BackgroundTransparency = 1
      nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
      nameLabel.Parent = billboard
      
      local healthLabel = Instance.new("TextLabel")
      healthLabel.Text = "Health: " .. math.round(player.Character.Humanoid.Health)
      healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
      healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
      healthLabel.BackgroundTransparency = 1
      healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
      healthLabel.Parent = billboard
      
      billboard.Parent = player.Character:FindFirstChild("Head")
      table.insert(ESPInstances, billboard)
      
      player.Character.Humanoid.HealthChanged:Connect(function()
         healthLabel.Text = "Health: " .. math.round(player.Character.Humanoid.Health)
      end)
   end
end

local function RemoveESP()
   for _, inst in ipairs(ESPInstances) do
      inst:Destroy()
   end
   ESPInstances = {}
end

local WallHackToggle = MainTab:CreateToggle({
   Name = "Enable WallHack (ESP)",
   CurrentValue = false,
   Flag = "WallHackToggle",
   Callback = function(Value)
      WallHackEnabled = Value
      if Value then
         for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
               CreateESP(player)
            end
         end
         Players.PlayerAdded:Connect(function(player)
            if WallHackEnabled and player ~= LocalPlayer then
               player.CharacterAdded:Connect(function()
                  CreateESP(player)
               end)
            end
         end)
      else
         RemoveESP()
      end
   end,
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("Script Controls")

SettingsTab:CreateButton({
   Name = "Unload Script",
   Callback = function()
      if AimbotConnection then
         AimbotConnection:Disconnect()
      end
      RemoveESP()
      fovCircleGui:Destroy()
      Rayfield:Destroy()
   end,
})

SettingsTab:CreateSection("Customization")

SettingsTab:CreateColorPicker({
   Name = "FOV Circle Color",
   Color = FOVColor,
   Flag = "FOVColor",
   Callback = function(Color)
      FOVColor = Color
      UpdateFOVCircle(FOV, Color)
   end
})

SettingsTab:CreateColorPicker({
   Name = "ESP Highlight Color",
   Color = ESPColor,
   Flag = "ESPColor",
   Callback = function(Color)
      ESPColor = Color
      UpdateESPColor(Color)
   end
})

Rayfield:Notify({
   Title = "Cheats Loaded",
   Content = "Aimbot with visible FOV circle and WallHack ESP ready. Use Settings tab to unload or change colors."
})
