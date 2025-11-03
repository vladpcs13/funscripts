local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "BABFT Auto Farm | by vladpcs13 (Beta Test)",
    LoadingTitle = "BABFT Auto Farm",
    LoadingSubtitle = "by vladpcs13",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "vladpcs13scripts",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local SettingsTab = Window:CreateTab("Farm Settings", 4483362458)


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer


local teleporting = false
local noclipConn, antiFallBV
local FarmSpeed = 1
local FarmDelay = 0
local WaitAtEnd = 19


local positions = {
    Vector3.new(-40, 35, 1371),
    Vector3.new(-61, 33, 2140),
    Vector3.new(-76, 41, 2909),
    Vector3.new(-87, 42, 3678),
    Vector3.new(-41, 48, 4450),
    Vector3.new(-88, 54, 5220),
    Vector3.new(-63, 49, 5990),
    Vector3.new(-83, 63, 6759),
    Vector3.new(-64, 51, 7530),
    Vector3.new(-99, 49, 8298),
    Vector3.new(-120, 179, 9132),
    Vector3.new(-56, -359, 9496)
}


local function waitForCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    return char, hrp, humanoid
end

local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end
        end
    end)
end

local function disableNoclip() 
    if noclipConn then 
        noclipConn:Disconnect() 
        noclipConn = nil 
    end 
end

local function preventFalling(hrp)
    if not antiFallBV then
        antiFallBV = Instance.new("BodyVelocity")
        antiFallBV.Velocity = Vector3.new(0, 0, 0)
        antiFallBV.MaxForce = Vector3.new(0, math.huge, 0)
        antiFallBV.Parent = hrp
    end
end

local function allowFalling() 
    if antiFallBV then 
        antiFallBV:Destroy() 
        antiFallBV = nil 
    end 
end

local function tweenTo(hrp, pos)
    local tweenInfo = TweenInfo.new(FarmSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

local function restartAfterRespawn()
    local _, _, humanoid = waitForCharacter()
    repeat task.wait(0.2) until humanoid.Health >= humanoid.MaxHealth
    task.wait(2)
end


local function doFarm()
    task.spawn(function()
        while teleporting do
            local char, hrp, humanoid = waitForCharacter()
            if not char or not hrp or not humanoid then
                task.wait(1)
                continue
            end
            
            enableNoclip()
            preventFalling(hrp)
            local died = false
            local diedConn = humanoid.Died:Connect(function() 
                died = true 
            end)
            
            for i, pos in ipairs(positions) do
                if not teleporting or died then break end
                
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    break
                end
                
                tweenTo(hrp, pos)
                
                if i < #positions then 
                    task.wait(FarmDelay)
                else
                    allowFalling()
                    disableNoclip()
                    local waited = 0
                    while waited < WaitAtEnd and humanoid.Health > 0 and teleporting do
                        task.wait(1)
                        waited += 1
                    end
                end
            end
            diedConn:Disconnect()
            if died then 
                restartAfterRespawn() 
            end
            task.wait(0.1)
        end
        allowFalling()
        disableNoclip()
    end)
end


local FarmToggle = MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(Value)
        teleporting = Value
        if teleporting then
            Rayfield:Notify({
                Title = "Farm",
                Content = "Farm started!",
                Duration = 3
            })
            doFarm()
        else
            Rayfield:Notify({
                Title = "Farm",
                Content = "Farm stopped!",
                Duration = 3
            })
        end
    end,
})


local SpeedSlider = SettingsTab:CreateSlider({
    Name = "Farm Speed",
    Range = {0.5, 10},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = FarmSpeed,
    Flag = "FarmSpeed",
    Callback = function(Value)
        FarmSpeed = Value
    end,
})

local DelaySlider = SettingsTab:CreateSlider({
    Name = "Delay Between Points",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = FarmDelay,
    Flag = "FarmDelay",
    Callback = function(Value)
        FarmDelay = Value
    end,
})

local WaitSlider = SettingsTab:CreateSlider({
    Name = "Wait Time at End",
    Range = {5, 30},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = WaitAtEnd,
    Flag = "WaitAtEnd",
    Callback = function(Value)
        WaitAtEnd = Value
    end,
})


SettingsTab:CreateSection("Warning")
local InfoLabel = SettingsTab:CreateLabel("Not recommended to change this settings")

Rayfield:LoadConfiguration()
