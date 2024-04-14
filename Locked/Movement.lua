local function infinite_Stamina(number) --// You can also hook the value instead
    local plr = game.Players.LocalPlayer
    local stamina = plr.PlayerGui.GeneralGUI.CurrentStamina.STAM
    stamina:SetAttribute("MaxSTAM", number)
    stamina.Value = number
end

local function disableJumpFatigue()
    game.Players.LocalPlayer.Character.Movement.JumpFatigue.Disabled = true
end

local function antiRagdoll()
    local event = game.ReplicatedStorage.Ragdoll
    local old;
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if self == event and method == "FireServer" then
            return nil
        end

        return old(self, unpack(args))
    end)
end

infinite_Stamina(4000)
disableJumpFatigue()
antiRagdoll()