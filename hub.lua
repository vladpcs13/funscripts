local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "vladpcs13's home",
    LoadingTitle = "vladpcs13's home",
    LoadingSubtitle = "by vladpcs13",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "vladpcs13",
        FileName = "config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

local GeneralTab = Window:CreateTab("General", 4483345998)
local AboutTab = Window:CreateTab("About", 4483345998)

GeneralTab:CreateSection("Scripts")

GeneralTab:CreateButton({
    Name = "Slap Battles",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/AutoSlap.lua",true))()
    end,
})

GeneralTab:CreateButton({
    Name = "Build a boat for a Treasure (beta)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/babft.lua",true))()
    end,
})

GeneralTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
    end,
})

GeneralTab:CreateButton({
    Name = "Unvisible",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/Unvisible/refs/heads/main/UnvisibleRework.lua",true))()
    end,
})

GeneralTab:CreateButton({
    Name = "SkillHelper",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/SkillHelper.lua",true))()
    end,
})

AboutTab:CreateSection("About vladpcs13")

AboutTab:CreateParagraph({
    Title = "vladpcs13",
    Content = "vladpcs13 its fun roblox developer and script creator. This hub contains various useful scripts for different games."
})

AboutTab:CreateParagraph({
    Title = "Scripts",
    Content = "Available scripts: Slap Battles, Unvisible, SkillHelper and more to come!"
})

AboutTab:CreateParagraph({
    Title = "Updates",
    Content = "Regular updates and new scripts will be added to this hub. Stay tuned!"
})

Rayfield:LoadConfiguration()
