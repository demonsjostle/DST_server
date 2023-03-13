local assets = 
{
	Asset("ANIM", "anim/ladle.zip"),
	Asset("ATLAS", "images/inventoryimages/ladddle.xml"),
    Asset("IMAGE", "images/inventoryimages/ladddle.tex"),
}

local SPAWN_DIST = 30

local function OpenEye(inst)
	inst.isOpenEye = true
	inst.components.inventoryitem:ChangeImageName(inst.openEye)
end

local function CloseEye(inst)
	inst.isOpenEye = nil
	inst.components.inventoryitem:ChangeImageName(inst.closedEye)
end

local function RefreshEye(inst)
	if inst.isOpenEye then
		OpenEye(inst)
	else
		CloseEye(inst)
	end
end

local function GetSpawnPoint(pt)
	local theta = math.random() * 2 * PI
	local radius = SPAWN_DIST
	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	return offset ~= nil and (pt + offset) or nil
end

local function Spawnstovester(inst)
	local pt = inst:GetPosition()
	local spawn_pt = GetSpawnPoint(pt)
	if spawn_pt ~= nil then
		local stovester = SpawnPrefab("stovester")
		if stovester ~= nil then
			stovester.Physics:Teleport(spawn_pt:Get())
			stovester:FacePoint(pt:Get())
			return stovester
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

local function Rebindstovester(inst, stovester)
	if not TheWorld.ismastersim then
		return inst
	end
	stovester = stovester or TheSim:FindFirstEntityWithTag("stovester")
	if stovester ~= nil then
		inst.AnimState:PlayAnimation("ladlealive", true)
		OpenEye(inst)
		inst:ListenForEvent("death", function() 
			StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME) 
		end, stovester)
		if stovester.components.follower.leader ~= inst then
			stovester.components.follower:SetLeader(inst)
		end
		return true
	end
end

local function Respawnstovester(inst)
	StopRespawn(inst)
	Rebindstovester(inst, TheSim:FindFirstEntityWithTag("stovester") or Spawnstovester(inst))
end

StartRespawn = function(inst, time)
	StopRespawn(inst)
	time = time or 0
	inst.respawntask = inst:DoTaskInTime(time, Respawnstovester)
	inst.respawntime = GetTime() + time
	inst.AnimState:PlayAnimation("ladledead", true)
	CloseEye(inst)
end

local function Fixstovester(inst)
	inst.fixtask = nil
	if not Rebindstovester(inst) then
		inst.AnimState:PlayAnimation("ladledead", true)
		CloseEye(inst)
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
		inst.fixtask = inst:DoTaskInTime(1, Fixstovester)
	end
end

local function OnSave(inst, data)
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

    inst:AddTag("ladle")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

	inst.AnimState:SetBank("ladle")
	inst.AnimState:SetBuild("ladle")
	inst.AnimState:PlayAnimation("ladlealive", true)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.entity:SetPristine()
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/ladddle.xml"

	inst:AddComponent("leader")

	inst.openEye = "ladddle" -- to ladle when you make the inventoryimage
	inst.closedEye = "ladddle" -- to ladle_closed when you make the inventoryimage

	inst.isOpenEye = nil
	OpenEye(inst)

	MakeHauntableLaunch(inst)

	inst.OnLoad = OnLoad
	inst.OnSave = OnSave

	inst.fixtask = inst:DoTaskInTime(1, Fixstovester)

	return inst
end

return Prefab("common/inventory/ladle", fn, assets)
