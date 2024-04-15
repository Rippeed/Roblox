--// MAIN SETTINGS //--
getgenv().noYenChange = true --// Refrain yen from going out of ur account when rolling

--// ROLL SETTINGS //--
getgenv().skipAnimation = true --// Highly recommended to keep it on
getgenv().rollType = "Weapon" --// Choices: "Trait" or "Weapon"
getgenv().toRoll = {"Shadow"} --// What you want to roll

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


local oldweapon;
local oldtrait;
local function autoRoll()
    if getgenv().skipAnimation == true then
        local func = getTraitAnim()
        local sfunc = getWeaponAnim()
        if func == nil or sfunc == nil then 
            warn("⚠️ Functions fetched are nil! Consider rejoining the game ⚠️")
            print("⛔ Stopping script")
            return
        end
        oldtrait = hookfunction(func, function(self, ...)
            return nil
        end)

        oldweapon = hookfunction(sfunc, function(self, ...)
            return nil
        end)
    end

    if getgenv().IS_YEN_HOOKED == false then
        noYenChange()
    end

    local currentRoll = nil
    local pathtovalues = getPath(getgenv().rollType)
    if pathtovalues == nil then return end

    
    local a;
    local changefunction = getChangeWeaponFunc()
    task.spawn(function()
        if getgenv().rollType == "Trait" or "Weapon" then
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
        end
    end)


    local pathtoremote = getRemote(getgenv().rollType)
    task.spawn(function()
        while task.wait(0.3) do  
            if table.find(getgenv().toRoll, currentRoll) then
                print("✅ - Successfully rolled; "..currentRoll)
                print("If you don't see the roll in the menu, just rejoin the game 🔄")
                a:Disconnect()
                restorefunction(oldtrait)
                restorefunction(oldweapon) 
                break
            end
            pathtoremote:FireServer()
        end
    end)
end

--// Initialization //--
if getgenv().rollType == "Height" then
    if string.find(getgenv().toRoll, "'") then
        for i,v in pairs(heights) do
            if v == getgenv().toRoll then
                getgenv().toRoll = i
            end
        end
    elseif getgenv().toRoll == "6" then
        getgenv().toRoll = 10 --// 10 == 6 foot
    end
end

for i = 1, 3 do
    print("⏳ Starting in..".. i)
    task.wait(0.5)
end

autoRoll()

