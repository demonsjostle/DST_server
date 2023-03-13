local assets =
{
    Asset("ANIM", "anim/afestertoy.zip"),
    Asset("ANIM", "anim/afestertoy_build.zip"),
    Asset("ANIM", "anim/spistertoy_build.zip"),
    Asset("ANIM", "anim/slustertoy_build.zip"),
    Asset("ATLAS", "images/inventoryimages/afestertoy.xml"),
    Asset("IMAGE", "images/inventoryimages/afestertoy.tex"),
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
	
local function RefreshToy(inst)
    if inst.isAlive then
        Alive(inst)
    else
        Bucket(inst)
    end
end


local function MorphSpistertoy(inst)
    inst.AnimState:SetBuild("spistertoy_build")

    inst.Alive = "spistertoy_alive"
    inst.Bucket = "spistertoy_dead"
    RefreshToy(inst)

    inst.AfestertoyState = "SPISTER"
end

local function MorphSlustertoy(inst)
    inst.AnimState:SetBuild("slustertoy_build")

    inst.Alive = "slustertoy_alive"
    inst.Bucket = "slustertoy_dead"
    RefreshToy(inst)

    inst.AfestertoyState = "SLUSTER"
end

local function MorphSpitstertoy(inst)
    inst.AnimState:SetBuild("spistertoy_build")

    inst.Alive = "spistertoy_alive"
    inst.Bucket = "spistertoy_dead"
    RefreshToy(inst)

    inst.AfestertoyState = "SPITSTER"
end

local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST
	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	return offset ~= nil and (pt + offset) or nil
end

local function SpawnAfester(inst)
    local pt = inst:GetPosition()        
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        local afester = SpawnPrefab("afester")
        if afester ~= nil then
            afester.Physics:Teleport(spawn_pt:Get())
            afester:FacePoint(pt:Get())
            return afester
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


local function RebindAfester(inst, afester)
    if not TheWorld.ismastersim then
        return inst
    end
    afester = afester or TheSim:FindFirstEntityWithTag("afester")
    if afester ~= nil then
        inst.AnimState:PlayAnimation("idle_loop", true)
        Alive(inst)
        inst:ListenForEvent("death", function() 
		    StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME) 
		end, afester)
        if afester.components.follower.leader ~= inst then
            afester.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnAfester(inst)
    StopRespawn(inst)
    RebindAfester(inst, TheSim:FindFirstEntityWithTag("afester") or SpawnAfester(inst))
end

StartRespawn = function(inst, time)
    StopRespawn(inst)
    time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnAfester)
    inst.respawntime = GetTime() + time
    inst.AnimState:PlayAnimation("dead_idle_loop", true)
    Bucket(inst)
end

local function FixAfester(inst)
	inst.fixtask = nil
	if not RebindAfester(inst) then
        inst.AnimState:PlayAnimation("dead_idle_loop", true)
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
        inst.fixtask = inst:DoTaskInTime(1, FixAfester)
    end
end

local function OnSave(inst, data)
    data.AfestertoyState = inst.AfestertoyState
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

    if data.AfestertoyState == "SPISTER" then
        MorphSpistertoy(inst)
    elseif data.AfestertoyState == "SLUSTER" then
        MorphSlustertoy(inst)
    elseif data.AfestertoyState == "SPITSTER" then
        MorphSpitstertoy(inst)
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

    inst:AddTag("afestertoy")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")
	
    inst.AnimState:SetBank("afestertoy")
    inst.AnimState:SetBuild("afestertoy_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/afestertoy.xml"

    inst.AfestertoyState = "AFESTER"
    inst.Alive = "afestertoy_alive"
    inst.Bucket = "afestertoy_dead"

    inst.isAlive = nil
    Alive(inst)
		
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")

    MakeHauntableLaunch(inst)

    inst.MorphSlustertoy = MorphSlustertoy
    inst.MorphSpistertoy = MorphSpistertoy
    inst.MorphSpitstertoy = MorphSpitstertoy

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
	
	inst.fixtask = inst:DoTaskInTime(1, FixAfester)

    return inst
end

return Prefab("common/inventory/afestertoy", fn, assets)