local DilLib = loadstring(game:HttpGet('ССЫЛКА_НА_ВАШ_DILUI.LUA'))()

local Window = DilLib:MakeWindow({
    Name = "vladpcs13's home",
    ConfigFolder = "vladpcs13",
    SaveConfig = true,
    KeyToOpenWindow = "K",
    IntroEnabled = true,
    IntroText = "vladpcs13's home",
    ShowIcon = false
})

local GeneralTab = Window:MakeTab({
    Name = "General",
    Icon = "rbxassetid://4483345998"
})

local AboutTab = Window:MakeTab({
    Name = "About",
    Icon = "rbxassetid://4483345998"
})

GeneralTab:AddLabel("Scripts")

GeneralTab:AddButton({
    Name = "Slap Battles",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/AutoSlap.lua", true))()
    end
})

GeneralTab:AddButton({
    Name = "Build a boat for a Treasure (beta)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/babft.lua", true))()
    end
})

GeneralTab:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
    end
})

GeneralTab:AddButton({
    Name = "Unvisible",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/Unvisible/refs/heads/main/UnvisibleRework.lua", true))()
    end
})

GeneralTab:AddButton({
    Name = "SkillHelper",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/vladpcs13/funscripts/refs/heads/main/SkillHelper.lua", true))()
    end
})

AboutTab:AddLabel("About vladpcs13")

AboutTab:AddParagraph("vladpcs13", "vladpcs13 its fun roblox developer and dalbaeb creator. This hub contains various useful scripts for different games.")

DilLib:Init()
