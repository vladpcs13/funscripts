local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "Slap Battles | Auto Slap", LoadingTitle = "Slap Battles | Auto Slap", LoadingSubtitle = "by vladpcs13"})
local MainTab = Window:CreateTab("Main")
local MiscTab = Window:CreateTab("Misc")
local autoActivateEnabled = true
local autoWalkEnabled = false
local connection
local function getChar()
return player.Character or player.CharacterAdded:Wait()
end
local function getRoot()
local char = getChar()
if not char then return end
return char:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
local char = getChar()
if not char then return end
return char:FindFirstChildOfClass("Humanoid")
end
local function getTool()
local char = getChar()
if not char then return end
local bp = player:FindFirstChild("Backpack")
if not bp then return end
for _, t in char:GetChildren() do
if t:IsA("Tool") and t:FindFirstChild("Handle") then
return t
end
end
for _, t in bp:GetChildren() do
if t:IsA("Tool") and t:FindFirstChild("Handle") then
return t
end
end
end
local function equipTool(tool)
if tool and tool.Parent == player.Backpack then
local char = getChar()
if char then
tool.Parent = char
repeat task.wait() until tool.Parent == char or not tool.Parent
end
end
end
local function start()
if connection then return end
connection = RunService.Heartbeat:Connect(function()
local root = getRoot()
if not root then return end
local char = getChar()
local humanoid = getHumanoid()
if not humanoid then return end
local tool = getTool()
if autoActivateEnabled then
if tool and tool.Parent == player.Backpack then
equipTool(tool)
if tool.Parent ~= char then return end
end
if tool and tool.Parent ~= char then return end
end
local nearestDist = math.huge
local nearestPos = nil
for _, p in Players:GetPlayers() do
if p == player then continue end
local oc = p.Character
if not oc then continue end
local orp = oc:FindFirstChild("HumanoidRootPart")
if not orp then continue end
local dist = (root.Position - orp.Position).Magnitude
if dist < nearestDist then
nearestDist = dist
nearestPos = orp.Position
end
if autoActivateEnabled and tool and dist <= 5 then
tool:Activate()
end
end
if autoWalkEnabled and nearestPos then
humanoid:MoveTo(nearestPos)
end
end)
end
local function stop()
if connection then
connection:Disconnect()
connection = nil
end
end
local function manageLoop()
if autoActivateEnabled or autoWalkEnabled then
start()
else
stop()
end
end
MainTab:CreateToggle({
Name = "Enable Auto Slap",
CurrentValue = true,
Callback = function(v)
autoActivateEnabled = v
manageLoop()
end
})
MainTab:CreateToggle({
Name = "Enable Auto Walk",
CurrentValue = false,
Callback = function(v)
autoWalkEnabled = v
manageLoop()
local root = getRoot()
local humanoid = getHumanoid()
if not v and root and humanoid then
humanoid:MoveTo(root.Position)
end
end
})
MiscTab:CreateButton({
Name = "Load Unvisible (its may unload this script)",
Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/Unvisible/refs/heads/main/UnvisibleRework.lua",true))()
end
})
MiscTab:CreateKeybind({
Name = "Auto Slap Bind",
CurrentKeybind = "Z",
HoldToToggle = false,
Callback = function(key)
autoActivateEnabled = not autoActivateEnabled
manageLoop()
end
})
MiscTab:CreateKeybind({
Name = "Auto Walk Bind",
CurrentKeybind = "X",
HoldToToggle = false,
Callback = function(key)
autoWalkEnabled = not autoWalkEnabled
manageLoop()
local root = getRoot()
local humanoid = getHumanoid()
if not autoWalkEnabled and root and humanoid then
humanoid:MoveTo(root.Position)
end
end
})
MiscTab:CreateButton({
Name = "Unload Script",
Callback = function()
stop()
Rayfield:Destroy()
end
})
player.CharacterAdded:Connect(function()
task.wait(1)
manageLoop()
if Rayfield and Rayfield.Parent ~= playerGui then
Rayfield.Parent = playerGui
end
end)
task.wait(1)
manageLoop()
