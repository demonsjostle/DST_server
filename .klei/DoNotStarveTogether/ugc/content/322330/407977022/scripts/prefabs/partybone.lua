local assets =
{
	Asset("ANIM", "anim/partybone.zip"),
	Asset("ATLAS", "images/inventoryimages/eyeboneinventory.xml"),
    Asset("IMAGE", "images/inventoryimages/eyeboneinventory.tex"),
}

local SPAWN_DIST = 30

local function Alive(inst)
    inst.isAlive = true
    inst.components.inventoryitem:ChangeImageName(inst.Alive)
end

local function Bucket(inst)
    inst.isAlive = nil
    inst.components.inventoryitem:ChangeImageName(inst.Bucket)
end
	
local function RefreshBone(inst)
    if inst.isAlive then
        Alive(inst)
    else
        Bucket(inst)
    end
end


local function MorphArmorsterbone(inst)
    inst.AnimState:SetBuild("partybone")

    inst.Alive = "idle_loop"
    inst.Bucket = "dead"
    RefreshBone(inst)

    inst.PartyboneState = "ARMORSTER"
end

local function MorphCookfoodsterbone(inst)
    inst.AnimState:SetBuild("partybone")

    inst.Alive = "idle_loop"
    inst.Bucket = "dead"
    RefreshBone(inst)

    inst.PartyboneState = "COOKFOODSTER"
end

local function MorphRawsterbone(inst)
    inst.AnimState:SetBuild("partybone")

    inst.Alive = "idle_loop"
    inst.Bucket = "dead"
    RefreshBone(inst)
	print ("partytime MorphRawsterbone")

    inst.PartyboneState = "RAWSTER"
end

local function MorphWeaponsterbone(inst)
    inst.AnimState:SetBuild("partybone")

    inst.Alive = "idle_loop"
    inst.Bucket = "dead"
    RefreshBone(inst)

    inst.PartyboneState = "WEAPONSTER"
end

local function MorphGemsterbone(inst)
    inst.AnimState:SetBuild("partybone")

    inst.Alive = "idle_loop"
    inst.Bucket = "dead"
    RefreshBone(inst)

    inst.PartyboneState = "GEMSTER"
end

local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST
	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	return offset ~= nil and (pt + offset) or nil
end

local function SpawnPartychester(inst)
    local pt = inst:GetPosition()        
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        local partychester = SpawnPrefab("partychester")
        if partychester ~= nil then
            partychester.Physics:Teleport(spawn_pt:Get())
            partychester:FacePoint(pt:Get())
            return partychester
        end
    end
end

local StartRespawn

local function StopRespawn(inst)
    if inst.respawntask ~= nil then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end


local function RebindPartychester(inst, partychester)
    if not TheWorld.ismastersim then
        return inst
    end
    partychester = partychester or TheSim:FindFirstEntityWithTag("partychester")
    if partychester ~= nil then
        inst.AnimState:PlayAnimation("idle_loop", true)
        Alive(inst)
        inst:ListenForEvent("death", function() StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME) end, partychester)

        if partychester.components.follower.leader ~= inst then
            partychester.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnPartychester(inst)
    StopRespawn(inst)
    RebindPartychester(inst, TheSim:FindFirstEntityWithTag("partychester") or SpawnPartychester(inst))
end

StartRespawn = function(inst, time)
    StopRespawn(inst)

    time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnPartychester)
    inst.respawntime = GetTime() + time
    inst.AnimState:PlayAnimation("dead", true)
    Bucket(inst)
end

local function FixPartychester(inst)
	inst.fixtask = nil
	if not RebindPartychester(inst) then
        inst.AnimState:PlayAnimation("dead", true)
        Bucket(inst)
		
		if inst.components.inventoryitem.owner ~= nil then
			local time_remaining = 0
			local time = GetTime()
			if inst.respawntime and inst.respawntime > time then
				time_remaining = inst.respawntime - time		
			end
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
    if inst.fixtask == nil then
        inst.fixtask = inst:DoTaskInTime(1, FixPartychester)
    end
end

local function OnSave(inst, data)
    data.PartyboneState = inst.PartyboneState
    if inst.respawntime ~= nil then
        local time = GetTime()
        if inst.respawntime > time then
            data.respawntimeremaining = inst.respawntime - time
        end
    end
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.PartyboneState == "ARMORSTER" then
        MorphArmorsterbone(inst)
    elseif data.PartyboneState == "COOKFOODSTER" then
        MorphCookfoodsterbone(inst)
    elseif data.PartyboneState == "RAWSTER" then
        MorphRawsterbone(inst)
    elseif data.PartyboneState == "WEAPONSTER" then
        MorphWeaponsterbone(inst)
    elseif data.PartyboneState == "GEMSTER" then
        MorphGemsterbone(inst)
    end

    if data.respawntimeremaining ~= nil then
        inst.respawntime = data.respawntimeremaining + GetTime()
    end
end

local function GetStatus(inst)
    if inst.respawntask ~= nil then
        return "WAITING"
    end
end
	
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("partybone")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")
	
    inst.AnimState:SetBank("partybone")
    inst.AnimState:SetBuild("partybone")
    inst.AnimState:PlayAnimation("idle_loop", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/eyeboneinventory.xml"

    inst.PartyboneState = "DUBSTER"
    inst.Alive = "partystickalive"
    inst.Bucket = "partystickdead"

    inst.isAlive = nil
    Alive(inst)
		
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")

    MakeHauntableLaunch(inst)

    inst.MorphArmorsterbone = MorphArmorsterbone
    inst.MorphCookfoodsterbone = MorphCookfoodsterbone
    inst.MorphRawsterbone = MorphRawsterbone
    inst.MorphWeaponsterbone = MorphWeaponsterbone
    inst.MorphGemsterbone = MorphGemsterbone

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
	
	inst.fixtask = inst:DoTaskInTime(1, FixPartychester)

    return inst
end

return Prefab("common/inventory/partybone", fn, assets)