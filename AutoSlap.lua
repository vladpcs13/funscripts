local DilLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/DilUI.lua'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local ignoreFriendsEnabled = false
local desiredWalkSpeed = 16
local friendList = {}

local antiVoidEnabled = false
local lastSafeCFrame = nil
local recovering = false

local maxControlVelocity = 85
local autoActivateEnabled = true
local autoWalkEnabled = false
local autoTeleportEnabled = false
local rainbowMode = false
local espEnabled = true
local customColor = Color3.fromRGB(255, 0, 50)
local currentTarget = nil
local teleportPoint = Vector3.new(-1208, 328, 3)

local highlight = Instance.new("Highlight")
highlight.Name = "DIL.SLAP"
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0
highlight.Parent = game:GetService("CoreGui")
task.spawn(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            pcall(function() if player:IsFriendsWith(p.UserId) then friendList[p] = true end end)
        end
    end
    Players.PlayerAdded:Connect(function(p)
        pcall(function() if player:IsFriendsWith(p.UserId) then friendList[p] = true end end)
    end)
    Players.PlayerRemoving:Connect(function(p)
        friendList[p] = nil
    end)
end)

local function getChar(plr) return plr and plr.Character end
local function getRoot(plr) 
    local char = getChar(plr or player)
    return char and char:FindFirstChild("HumanoidRootPart") 
end
local function getHum(plr)
    local char = getChar(plr or player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getTool()
    local char = getChar(player)
    if not char then return end
    return char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
end

local function getBestTarget()
    local myRoot = getRoot()
    if not myRoot then return nil end
    
    local nearestDist = math.huge
    local target = nil
    
    for _, p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        if ignoreFriendsEnabled and friendList[p] then continue end 
        
        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and hum and hum.Health > 0 and root.Position.Y > -20 then
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                target = p
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if rainbowMode then
        customColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
    
    if espEnabled and currentTarget and currentTarget.Character then
        highlight.Adornee = currentTarget.Character
        highlight.FillColor = customColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Enabled = true
    else
        highlight.Enabled = false
    end
end)

task.spawn(function()
    while task.wait() do
        local myRoot = getRoot()
        local myHum = getHum()
        if not myRoot or not myHum then continue end
        
        currentTarget = getBestTarget()
        
        if currentTarget then
            local tRoot = getRoot(currentTarget)
            local tool = getTool()
            
            if tRoot then
                local dist = (myRoot.Position - tRoot.Position).Magnitude
                
                if autoActivateEnabled and tool then
                    if tool.Parent ~= player.Character then
                        tool.Parent = player.Character
                    end
                    if dist < 20 then
                        tool:Activate()
                    end
                end
                
                if autoWalkEnabled then
                    myHum:MoveTo(tRoot.Position)
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(tRoot.Position.X, myRoot.Position.Y, tRoot.Position.Z))
                end
            end
        end
    end
end)


player.CharacterAdded:Connect(function(char)
    if autoTeleportEnabled then
        task.wait(2)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            hrp.CFrame = CFrame.new(teleportPoint)
        end
    end
end)


local Window = DilLib:MakeWindow({
    Name = "DIL.SLAP",
    ConfigFolder = "dilslap",
    SaveConfig = true,
    KeyToOpenWindow = "M"
})

local MainTab = Window:MakeTab({Name = "Main", Icon = "zap"})
local VisTab = Window:MakeTab({Name = "Visuals", Icon = "eye"})

local MainSection = MainTab:AddSection({Name = "Rage Settings"})

MainSection:AddToggle({
    Name = "Авто слап",
    Default = true,
    Callback = function(v) 
        autoActivateEnabled = v 
    end
})

MainSection:AddToggle({
    Name = "Авто ходьба",
    Default = false,
    Callback = function(v) 
        autoWalkEnabled = v 
        if not v then
            local hrp = getRoot()
            local hum = getHum()
            if hrp and hum then hum:MoveTo(hrp.Position) end
        end
    end
})

task.spawn(function()
    while task.wait(0.05) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and hum and hum.Health > 0 then
            hum.WalkSpeed = desiredWalkSpeed

            local isOnGround = hum.FloorMaterial ~= Enum.Material.Air
            local velocity = root.Velocity.Magnitude
            
            local isMovingReady = hum.MoveDirection.Magnitude > 0

            if isOnGround and not hum.Sit and velocity < (hum.WalkSpeed + 10) then
                lastSafeCFrame = root.CFrame
            end

            if antiVoidEnabled and not recovering then
                local lostControl = false
                
                if velocity > maxControlVelocity and not isMovingReady then 
                    lostControl = true 
                end
                
                if root.Position.Y < 15 then 
                    lostControl = true 
                end
                
                if hum.Sit and root.Position.Y < 25 then 
                    lostControl = true 
                end

                if lostControl and lastSafeCFrame then
                    recovering = true
                    
                    root.Velocity = Vector3.new(0, 0, 0)
                    root.RotVelocity = Vector3.new(0, 0, 0)
                    root.CFrame = lastSafeCFrame
                    
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    task.wait(0.3) 
                    recovering = false
                end
            end
        end
    end
end)

MainSection:AddToggle({
    Name = "Авто тп на арену после смерти",
    Default = false,
    Callback = function(v) autoTeleportEnabled = v end
})

MainSection:AddToggle({
    Name = "Не трогать друзей",
    Default = false,
    Callback = function(v)
        ignoreFriendsEnabled = v
    end
})

MainSection:AddToggle({
    Name = "Анти отдача",
    Default = false,
    Callback = function(v)
        antiVoidEnabled = v
    end
})

MainSection:AddSlider({
    Name = "Скорость бега",
    Min = 16,
    Max = 150,
    Default = 16,
    Callback = function(v)
        desiredWalkSpeed = v
    end
})


local VisSection = VisTab:AddSection({Name = "Target ESP"})

VisSection:AddToggle({
    Name = "Включить ЕСП у врага",
    Default = true,
    Callback = function(v) espEnabled = v end
})

VisSection:AddToggle({
    Name = "Радужный режим",
    Default = false,
    Callback = function(v) rainbowMode = v end
})

VisSection:AddColorpicker({
    Name = "Цвет",
    Default = Color3.fromRGB(255, 0, 50),
    Callback = function(color) customColor = color end
})

DilLib:Init()
