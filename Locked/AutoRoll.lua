--// MAIN SETTINGS //--
getgenv().noYenChange = true --// Refrain yen from going out of ur account when rolling

--// ROLL SETTINGS //--
getgenv().skipAnimation = true --// Highly recommended to keep it on
getgenv().rollType = "Trait" --// Choices: "Trait" or "Weapon"
getgenv().toRoll = {"Clamps"} --// What you want to roll


--// FUNCTIONS //--
local isHookedYen = false
local function noYenChange()
    local event = game:GetService("ReplicatedStorage").yenchange
    isHookedYen = true
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

local function getAnimFunc()
    for i, v in pairs(getgc()) do
        if type(v) == 'function' then
            if string.find(debug.info(v, "s"), "NewGacha") and debug.info(v, "n") == "weaponroll"  then
                return v
            end
        end
    end
end

local func = nil
local function autoRoll()
    if getgenv().skipAnimation == true then
        func = getAnimFunc()
        local old;
        old = hookfunction(func, function(self, ...)
            return nil
        end)
    end

    if isHookedYen == false then
        noYenChange()
    end

    local currentRoll = nil
    local pathtovalues;
    if getgenv().rollType == "Trait" then
        pathtovalues = game.Players.LocalPlayer.Backpack["Trait"]
    elseif getgenv().rollType == "Weapon" then
        pathtovalues = game.Players.LocalPlayer.Backpack
    else
        warn("rollType has not been correctly specified, contact the developer if you think this error is a mistake!")
        warn("rollType has not been correctly specified, contact the developer if you think this error is a mistake!")
        warn("rollType has not been correctly specified, contact the developer if you think this error is a mistake!")
        return
    end
    
    local a;
    task.spawn(function()
        a = pathtovalues.ChildAdded:Connect(function(inst)
            currentRoll = inst.Name
            print(currentRoll)
        end)
    end)


    --// WIP //--
    local pathtoremote = game:GetService("ReplicatedStorage").rerolls.traitreroll
    task.spawn(function()
        while task.wait(0.3) do  
            task.spawn(function()
                if table.find(getgenv().toRoll, currentRoll) then
                    print("Successfully rolled; "..currentRoll)
                    a:Disconnect()
                    restorefunction(func)
                    break
                end
            end)
            pathtoremote:FireServer()
        end
    end)
end