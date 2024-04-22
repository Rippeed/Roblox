--// MAIN SETTINGS //--
getgenv().noYenChange = true --// Refrain yen from going out of ur account when rolling

--// ROLL SETTINGS //--
getgenv().skipAnimation = true --// Highly recommended to keep it on
getgenv().rollType = "Weapon" --// Choices: "Trait", "Weapon" or "Height"
getgenv().toRoll = "" --// What you want to roll

getgenv().buffType = "Hitbox" --// For rolling hitbox


--// Settings table //--
local Settings = {
    antiRagdoll = false,
}

local IS_ROLLING = false

--// TABLES //--
local heights = {
    [1] = "5'3",
    [2] = "5'4",
    [3] = "5'5",
    [4] = "5'6",
    [5] = "5'7",
    [6] = "5'8",
    [7] = "5'9",
    [8] = "5'10",
    [9] = "5'11",
    [10] = "6",
    [11] = "6'1",
    [12] = "6'2",
    [13] = "6'3"
}

local weapons = {
    "Acrobatic",
    "Chigiri",
    "CopyCat",
    "DirectShot",
    "Emperor",
    "Formless",
    "IronHead",
    "King",
    "Kunigami",
    "Leader",
    "LongLegs",
    "Monster",
    "Nagi",
    "Neurotic",
    "Repel",
    "Riptide",
    "Serpent",
    "Shadow",
    "Snatch",
    "Voracious",
    "Web",
    "GodSpeed"
}

local traits = {
    "Ambidextrous",
    "Athlete",
    "Bunnys",
    "Clamps",
    "Claw",
    "Diver",
    "Egoist",
    "Fortune",
    "GoldenZone",
    "Heavy",
    "Lazy",
    "LongStrides",
    "Metavision",
    "NoLook",
    "Powerhouse",
    "Puppeteer",
    "Ripper",
    "Surf",
    "Tank",
    "Tired",
    "Tireless",
    "Unbreakable",
    "Weak"
}

local faces = {
    "Isagi",
    "Anri",
    "Chigiri",
    "Agi",
    "Silva",
    "Kurona",
    "Nagi",
    "Barou",
    "Bachira",
    "Reo",
    "Shidou",
    "Pablo",
    "Prince",
    "Rin",
    "Kunigami",
}

local buffvalues = {
    "5=<",
    "6=<",
    "7=<",
    "8=<",
    "9=<",
    "10=<",
    "11=<",
    "12=<",
    "13=<",
    "14=<",
    "15",
}


--// FUNCTIONS //--
getgenv().IS_YEN_HOOKED = false
local function noYenChange()
    local event = game:GetService("ReplicatedStorage").yenchange
    getgenv().IS_YEN_HOOKED = true
    local old;
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if self == event and method == "FireServer"  then
            if tonumber(args[1]) < 0 then
                args[1] = 0
            end
        end

        return old(self, unpack(args))
    end)
end

if getgenv().noYenChange == true then
    noYenChange()
end

local function getTraitAnim()
    for i, v in pairs(getgc()) do
        if type(v) == 'function' then
            if string.find(debug.info(v, "s"), "NewGacha") and debug.info(v, "n") == "weaponroll"  then
                return v
            end
        end
    end
end

local function getChangeWeaponFunc()
    for i,v in pairs(getgc()) do
        if type(v) == 'function' then
            if string.find(debug.info(v, "s"), "NewSystem") and debug.info(v, "n") == "changeweapon" then
                return v
            end
        end
    end
end

local function getWeaponAnim()
    for i, v in pairs(getgc()) do
        if type(v) == 'function' then
            if string.find(debug.info(v, "s"), "NewSystem") and debug.info(v, "n") == "weaponroll"  then
                return v
            end
        end
    end
end

local function translateHeight(height)
    if getgenv().rollType == "Height" then
        if string.find(getgenv().toRoll, "'") then
            if getgenv().toRoll == "6'0" then return 10 end
            for i,v in pairs(heights) do
                if v == getgenv().toRoll then
                    return i
                end
            end
        elseif getgenv().toRoll == "6" then
            return 10 --// 10 == 6 foot
        elseif tonumber(getgenv().toRoll) >= 1 and tonumber(getgenv().toRoll) <= 12 then
            return tonumber(getgenv().toRoll)
        end
    end
end

local function getRemote(rolltype)
    local gamefolder = game:GetService("ReplicatedStorage"):FindFirstChild("rerolls")
    if rolltype == "Trait" then
        return gamefolder["traitreroll"]
    elseif rolltype == "Weapon" then
        return gamefolder["specreroll"]
    elseif rolltype == "Height" then
        return gamefolder["heightreroll"]
    elseif rolltype == "Face" then
        return gamefolder["facereroll"]
    elseif rolltype == "Buff" then
        return gamefolder["buffreroll"]
    end
end

local function getPath(rolltype)
    local backpack = game.Players.LocalPlayer.Backpack
    local char = game.Players.LocalPlayer.Character

    if rolltype == "Trait" then
        return backpack["Trait"]
    elseif rolltype == "Weapon" then
        return backpack
    elseif rolltype == "Height" then
        return char["HeightValue"]
    elseif rolltype == "Face" then
        return char["face"]["Decal"]
    elseif rolltype == "Buff" then
        return char["AuraColour"]["Buff"]
    else
        warn("rollType has not been correctly specified, contact the developer if you think this error is a mistake!")
        warn("rollType has not been correctly specified, contact the developer if you think this error is a mistake!")
        warn("rollType has not been correctly specified, contact the developer if you think this error is a mistake!")
        print("⛔ Stopping script")
        return nil
    end
end

local function getFaceName(id)
    if not id then return end
    for i,v in ipairs(workspace.Heads:GetChildren()) do
        if v:FindFirstChildOfClass("Decal").Texture == id then
            return v.Name
        end
    end
end

local function formattedBuff(buff)
    if not buff then return end
    local value = buff:GetAttribute("BuffValue") * 10 -- 1.345 -> 13.45

    local preformatted = string.format("%.1f", value)
    local bufftype = buff.Value
    local formatted = tostring(preformatted.. "% " .. bufftype)

    return formatted
end

local function getBuffInfo(buff)
    if not buff then return end
    local value = buff:GetAttribute("BuffValue") * 10
    local bufftype = tostring(buff.Value)

    return tonumber(value), bufftype
end


local oldweapon;
local oldtrait;
local function autoRoll()
    for i = 1, 3 do
        print("⏳ Starting in..".. i)
        task.wait(0.5)
    end

    if getgenv().skipAnimation == true and getgenv().rollType == "Weapon" or getgenv().rollType == "Trait" then
        local func = getTraitAnim()
        local sfunc = getWeaponAnim()
        if func == nil or sfunc == nil then 
            warn("⚠️ Game functions already hooked, continuing...⚠️")
        else
            oldtrait = hookfunction(func, function(self, ...)
                return nil
            end)
    
            oldweapon = hookfunction(sfunc, function(self, ...)
                return nil
            end)
        end
    end

    if getgenv().IS_YEN_HOOKED == false then
        noYenChange()
    end

    local currentRoll = nil
    local pathtovalues = getPath(getgenv().rollType)
    print(pathtovalues, pathtovalues.Parent)            
    if pathtovalues == nil then return end

    
    local a;
    local changefunction
    if getgenv().rollType == "Weapon" then
        changefunction = clonefunction(getChangeWeaponFunc())
    end
        if getgenv().rollType == "Trait" or getgenv().rollType == "Weapon" then
            a = pathtovalues.ChildAdded:Connect(function(inst)
                currentRoll = inst.Name
                print(currentRoll)
                if getgenv().rollType == "Weapon" then
                    changefunction(inst)
                end
            end)
        elseif getgenv().rollType == "Height" then
            a = pathtovalues:GetPropertyChangedSignal("Value"):Connect(function()
                currentRoll = pathtovalues.Value
                print(heights[currentRoll], currentRoll)
            end)
        elseif getgenv().rollType == "Face" then
            a = pathtovalues:GetPropertyChangedSignal("Texture"):Connect(function()
                currentRoll = getFaceName(pathtovalues.Texture)
                print(currentRoll)
            end)
        elseif getgenv().rollType == "Buff" then
            a = pathtovalues.AttributeChanged:Connect(function()
                currentRoll = formattedBuff(pathtovalues)
                print(currentRoll)
            end)
        end


    local pathtoremote = getRemote(getgenv().rollType)
    pathtoremote:FireServer()
    task.spawn(function()
        while task.wait(0.3) do  
            if getgenv().rollType == "Trait" or getgenv().rollType == "Weapon" then
                if getgenv().toRoll == currentRoll then
                    print("✅ - Successfully rolled; "..currentRoll)
                    print("If you don't see the roll in the menu, just rejoin the game 🔄")
                    IS_ROLLING = false
                    pass_notification("✅ Rolled; "..currentRoll, "If you don't see the roll in the menu, just rejoin the game 🔄")
                    a:Disconnect()
                    break
                end
            elseif getgenv().rollType == "Height" then
                local translatedtoroll = translateHeight(getgenv().toRoll)
                if translatedtoroll == currentRoll then
                    print("✅ Rolled; "..heights[currentRoll])
                    print("If you don't see the roll in the menu, just rejoin the game 🔄")
                    IS_ROLLING = false
                    pass_notification("✅ Rolled; "..heights[currentRoll], "If you don't see the roll in the menu, just rejoin the game 🔄")
                    a:Disconnect()
                    break
                end
            elseif getgenv().rollType == "Face" then
                if getgenv().toRoll == currentRoll then
                    print("✅ Rolled; "..currentRoll)
                    print("If you don't see the roll in the menu, just rejoin the game 🔄")
                    IS_ROLLING = false
                    pass_notification("✅ Rolled; "..currentRoll, "If you don't see the roll in the menu, just rejoin the game 🔄")
                    a:Disconnect()
                    break
                end
            elseif getgenv().rollType == "Buff" then
                local buffValue, buffType = getBuffInfo(pathtovalues)
                if buffValue >= tonumber(getgenv().toRoll) and buffType == string.lower(getgenv().buffType) then
                    print("✅ Rolled; "..currentRoll)
                    print("If you don't see the roll in the menu, just rejoin the game 🔄")
                    IS_ROLLING = false
                    pass_notification("✅ Rolled; "..currentRoll, "If you don't see the roll in the menu, just rejoin the game 🔄")
                    a:Disconnect()
                    break
                end
            end
            pathtoremote:FireServer()
        end
    end)
end

local function infinite_Stamina(number) --// You can also hook the value instead
    local plr = game.Players.LocalPlayer
    local stamina = plr.PlayerGui.GeneralGUI.CurrentStamina.STAM
    stamina:SetAttribute("MaxSTAM", number)
    stamina.Value = number
end

local function disableJumpFatigue(bool)
    game.Players.LocalPlayer.Character.Movement.JumpFatigue.Disabled = bool
end

--// UI //--
local Atlas = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/main/Atlas%20UI%20Library/source.lua"))()

local UI = Atlas.new({
    Name = "lockedK";
    ConfigFolder = "ripped.solutions";
    Color = Color3.fromRGB(100, 149, 237);
    Bind = "LeftControl";
    UseLoader = false;
})

local Main = UI:CreatePage("Main")
local Lobby = UI:CreatePage("Lobby")

--// Main //-- 
local movementSection = Main:CreateSection("Movement Settings")

--// movementSection //--
local infiniteStamineToggle = movementSection:CreateToggle({
    Name = "Toggle Infinite Stamina",
    Flag = "infiniteStaminaToggle",
    Callback = function(bool)
        if bool == true then
            infinite_Stamina(9999999)
        elseif bool == false then
            infinite_Stamina(100)
        end
    end,
})

local jumpFatigueToggle = movementSection:CreateToggle({
    Name = "Toggle Jump Fatigue",
    Flag = "jumpFatigueToggle",
    Callback = function(bool)
        disableJumpFatigue(bool)
    end,
})

local antiRagdollToggle = movementSection:CreateToggle({
    Name = "Toggle Anti Ragdoll",
    Flag = "antiRagdollToggle",
    Callback = function(bool)
        Settings.antiRagdoll = bool
    end,
})

--// Lobby //--
local autoRollSection = Lobby:CreateSection("Auto Roll Settings")

--// autoRollSection //--
autoRollSection:CreateButton({
	Name = "Auto Roll";
	Callback = function()
        if IS_ROLLING == true then return end
        autoRoll()
        IS_ROLLING = true

	end
})

local rollTypeDropdown = autoRollSection:CreateDropdown({
    Name = "Roll Type",
    Callback = function(item)
        getgenv().rollType = item
    end,
    Options = {"Trait", "Weapon", "Face", "Buff", "Height"},
    ItemSelecting = true,
    DefaultItemSelected = "Weapon"
})

local chooseRollDropdown = autoRollSection:CreateDropdown({
    Name = "Choose Roll",
    Callback = function(item)
        if getgenv().rollType == "Buff" then
            if string.sub(item, 2, 2) == "<" then
                getgenv().toRoll = string.sub(item, 1, 1)
            else
                getgenv().toRoll = string.sub(item, 1, 2)
            end
        else
            getgenv().toRoll = item
        end
    end,
    Options = {"empty"},
    ItemSelecting = true, 
    DefaultItemSelected = "Choose your roll here"
})

game:GetService("RunService").RenderStepped:Connect(function()
    local tbl = {}
    
    if getgenv().rollType == "Trait" then
        tbl = traits
        chooseRollDropdown:Update(tbl)
    elseif getgenv().rollType == "Weapon" then
        tbl = weapons
        chooseRollDropdown:Update(tbl)
    elseif getgenv().rollType == "Height" then
        tbl = {}
        for i,v in ipairs(heights) do
            table.insert(tbl, v)
        end
        chooseRollDropdown:Update(tbl)
    elseif getgenv().rollType == "Buff" then
        tbl  = buffvalues
        chooseRollDropdown:Update(tbl)
    end
end)

local buffWarning = autoRollSection:CreateParagraph("Select buff type")

local buffTypeDropdown = autoRollSection:CreateDropdown({
    Name = "Buff Type",
    Callback = function(item)
        getgenv().buffType = item
    end,
    Options = {"Hitbox", "Speed", "Power"},
    ItemSelecting = true, 
    DefaultItemSelected = "Hitbox"
}) 


function pass_notification(title, text)
    UI:Notify({
        Title = title;
        Content = text;
      })
end

UI:Toggle(true)


local ragdollevent = game.ReplicatedStorage.Ragdoll
local old;
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if self == ragdollevent and method == "FireServer" and Settings.antiRagdoll == true then
        return nil
    end

    return old(self, unpack(args))
end)