local Unchanged = "Unchanged"
local Enabled 	= "Enabled"

function IsEnabled(Setting)
    return (GetModConfigData(Setting) == Enabled)
end

function HasChanged(Setting)
    return (GetModConfigData(Setting) ~= Unchanged)
end

function Set(Key, Setting)
    Setting = GetModConfigData(Setting)

    if (Setting ~= Unchanged) then
        if (TUNING[Key] ~= nil) then
            TUNING[Key] = Setting
        end
    end
end

local function OnHaunt_RemoveItem(Prefab, Haunter)
    -- Consume 1 Telltale Heart
    -- We check for stacking incase other mods change it to a stackable item
    if ((Prefab.components.stackable ~= nil) and Prefab.components.stackable:IsStack()) then
        Prefab.components.stackable:Get():Remove()
    else
        Prefab:Remove()
    end

    return true
end

local function AddResurrector(Prefab)
    if (Prefab.components.hauntable == nil) then
        Prefab:AddComponent("hauntable")
    end

    -- This Tuning value tells the game to resurrect the player
    Prefab.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    Prefab.components.hauntable.cooldown = 0
    Prefab.components.hauntable:SetOnHauntFn(function () return true end)

    if (IsEnabled("usetags") or HasChanged("ReturnHotkey")) then
        Prefab:AddTag("resurrector")
    end

    if (Prefab.components.inventoryitem ~= nil) then
        Prefab.components.hauntable:SetOnHauntFn(OnHaunt_RemoveItem)
    end
end

local function Apply(Prefab)
    -- Don't do any Prefab stuff if tags are used
    if ((not IsEnabled("usetags")) and IsEnabled(Prefab)) then
        AddPrefabPostInit(Prefab, AddResurrector)
    end
end

Apply("campfire")
Apply("firepit")
Apply("coldfire")
Apply("coldfirepit")

if IsEnabled("reviver") then
    AddPrefabPostInit("reviver", AddResurrector)
end

if IsEnabled("skeleton") then
    local function AddResurrector_Skeleton(Prefab)
        AddResurrector(Prefab)

        Prefab.components.hauntable:SetOnHauntFn(function (inst, doer)
            local fx = GLOBAL.SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx:SetMaterial("stone")

            inst:Remove()

            return true
        end)
    end

    AddPrefabPostInit("skeleton",        AddResurrector_Skeleton)
    AddPrefabPostInit("skeleton_player", AddResurrector_Skeleton)
end

if IsEnabled("usetags") then
    -- Runs on all prefabs as i couldn't find a way to iterate through all prefabs post-all mods initialization
    AddPrefabPostInitAny(function(Prefab)
        -- Do not try to add "resurrector" if it's already there
        if ((Prefab ~= nil) and (Prefab.components ~= nil) and Prefab:HasTag("campfire") and (not Prefab:HasTag("resurrector"))) then
            AddResurrector(Prefab)
        end
    end)
end

Set("PORTAL_HEALTH_PENALTY",  "Health_Penalty_Portal")
Set("MAXIMUM_HEALTH_PENALTY", "Health_Penalty_Maximum")
Set("EFFIGY_HEALTH_PENALTY",  "Health_Penalty_Meat_Effigy")
Set("REVIVE_HEALTH_PENALTY",  "Health_Penalty_Generic")
Set("RESURRECT_HEALTH",       "Health_Respawn_Amount")

if HasChanged("ReturnHotkey") then
    -- This is how the game does it too!
    local function GetPortal()
        for Key, Value in pairs(GLOBAL.Ents) do
            if (Value:IsValid() and Value:HasTag("multiplayer_portal")) then
                return Value
            end
        end
    end

    local function ResurrectPlayerAt(Prefab, Player)
        local X, Y, Z = Prefab.Transform:GetWorldPosition()
        Player:PushEvent("respawnfromghost", {source = Prefab, user = Player})
        Player.Physics:Teleport(X, Y, Z)
    end

    local function ResurrectPlayer_Portal(Player)
        if GLOBAL.GetPortalRez(GLOBAL.TheNet:GetServerGameMode()) then
            local Portal = GetPortal()

            if (Portal ~= nil) then
                Player.Monkey_LastHauntTarget = Portal
                ResurrectPlayerAt(Portal, Player)
            end
        end
    end

    local function ResurrectPlayer(Player, Mode)
        if ((Mode == "Last") and (Player.Monkey_LastHauntTarget ~= nil)) then
            local X, Y, Z = Player.Monkey_LastHauntTarget.Transform:GetWorldPosition()

            -- If any are nil then the target doesn't exist anymore
            if ((X ~= nil) and (Y ~= nil) and (Z ~= nil)) then
                ResurrectPlayerAt(Player.Monkey_LastHauntTarget, Player)
            else
                Player.Monkey_LastHauntTarget = nil
                ResurrectPlayer_Portal(Player)
            end

        elseif (Mode == "Closest") then
            local X, Y, Z     = Player.Transform:GetWorldPosition()
            local Entities    = GLOBAL.TheSim:FindEntities(X, Y, Z, 1000, {"resurrector"}, nil, {"campfire", "structure", "multiplayer_portal"})
            local Resurrector = nil

            for _, Entity in ipairs(Entities) do
                if ((Entity ~= nil) and (Entity.components.attunable == nil)) then
                    Resurrector = Entity
                    break
                end
            end

            if (Resurrector ~= nil) then
                ResurrectPlayerAt(Resurrector, Player)
            else
                ResurrectPlayer_Portal(Player)
            end
        else
            ResurrectPlayer_Portal(Player)
        end
    end

    AddModRPCHandler(modname, "Monkey_ResurrectPlayer", ResurrectPlayer)

    -- Server Side Only
    if (GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated()) then
        AddPlayerPostInit(function (Player)
            Player:ListenForEvent("haunt", function (Ghost, Data)
                if ((Data ~= nil) and (Data.target ~= nil) and Data.target:HasTag("resurrector")) then
                    Ghost.Monkey_LastHauntTarget = Data.target
                end
            end)
        end)
    end

    -- Client Side Only
    if GLOBAL.TheNet:GetIsClient() then
        local Hotkey = GetModConfigData("ReturnHotkey")

        GLOBAL.TheInput:AddKeyUpHandler(GLOBAL["KEY_" .. Hotkey], function ()
            if GLOBAL.ThePlayer:HasTag("playerghost") then
                SendModRPCToServer(MOD_RPC[modname]["Monkey_ResurrectPlayer"], GetModConfigData("ReturnHotkey_Mode"))
            end
        end)
    end
end

if IsEnabled("NoPlayerSkeletons") then
    AddPrefabPostInit("skeleton_player", function (Prefab)
        -- This is how the game does it too!
        Prefab:Remove()
    end)
end

if IsEnabled("KeepInventory") then
    AddComponentPostInit("inventory", function (self)
        if self.inst:HasTag("player") then
            local Old_DropEverything = self.DropEverything

            self.DropEverything = function(self, ondeath, keepequip)
                if (ondeath) then
                    -- For WX-78's modules, they will be dropped!
                    if (self.inst.components.upgrademoduleowner ~= nil) then
                        -- The game pushes their modules into the ActiveItem slot(the mouse cursor), this prevents them from respawning correctly.
                        -- So drop it!
                        self.inst.components.inventory:DropActiveItem()
                    end
                end

                if (not ondeath) then
                    Old_DropEverything(self, ondeath, keepequip)
                end
            end
        end
    end)
end

if IsEnabled("SpawnProtection") then
    AddPlayerPostInit(function (Prefab)
        Prefab:ListenForEvent("respawnfromghost", function (inst)
            inst:DoTaskInTime(15 * GLOBAL.FRAMES, function (inst)
                if (inst.components.debuffable ~= nil) then
                    inst.components.debuffable:AddDebuff("spawnprotectionbuff", "spawnprotectionbuff")
                end
            end)
        end)
    end)
end

if HasChanged("KillMe") then
    local function KillPlayer(Player)
        -- Has to check for idle, otherwise it'll crash the server when spamming the button and respawning.
        if ((Player.components.health ~= nil) and (not Player.components.health:IsDead()) and ((Player.sg ~= nil) and Player.sg:HasStateTag("idle"))) then
            Player:PushEvent("death")
        end
    end

    AddModRPCHandler(modname, "Monkey_KillMe", KillPlayer)

    -- Client Side Only
    if GLOBAL.TheNet:GetIsClient() then
        local Hotkey = GetModConfigData("KillMe")

        GLOBAL.TheInput:AddKeyUpHandler(GLOBAL["KEY_" .. Hotkey], function ()
            if (not GLOBAL.ThePlayer:HasTag("playerghost")) then
                SendModRPCToServer(MOD_RPC[modname]["Monkey_KillMe"])
            end
        end)
    end
end
