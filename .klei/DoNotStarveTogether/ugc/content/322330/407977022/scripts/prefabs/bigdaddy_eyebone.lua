local assets = 
{
	Asset("ANIM", "anim/daddys_bone.zip"),
	Asset("ANIM", "anim/daddys_bone_build.zip"),
	Asset("ATLAS", "images/inventoryimages/eyeboneinventory.xml"),
    Asset("IMAGE", "images/inventoryimages/eyeboneinventory.tex"),
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

local function SpawnChester(inst)
	local pt = inst:GetPosition()
	local spawn_pt = GetSpawnPoint(pt)
	if spawn_pt ~= nil then
		local chester = SpawnPrefab("bigdaddy")
		if chester ~= nil then
			chester.Physics:Teleport(spawn_pt:Get())
			chester:FacePoint(pt:Get())
			return chester
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

local function RebindChester(inst, chester)
	if not TheWorld.ismastersim then
		return inst
	end
	chester = chester or TheSim:FindFirstEntityWithTag("bigdaddy")
	if chester ~= nil then
		inst.AnimState:PlayAnimation("idle_loop", true)
		OpenEye(inst)
		inst:ListenForEvent("death", function() 
			StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME) 
		end, chester)
		if chester.components.follower.leader ~= inst then
			chester.components.follower:SetLeader(inst)
		end
		return true
	end
end

local function RespawnChester(inst)
	StopRespawn(inst)
	RebindChester(inst, TheSim:FindFirstEntityWithTag("bigdaddy") or SpawnChester(inst))
end

StartRespawn = function(inst, time)
	StopRespawn(inst)
	time = time or 0
	inst.respawntask = inst:DoTaskInTime(time, RespawnChester)
	inst.respawntime = GetTime() + time
	inst.AnimState:PlayAnimation("dead", true)
	CloseEye(inst)
end

local function FixChester(inst)
	inst.fixtask = nil
	if not RebindChester(inst) then
		inst.AnimState:PlayAnimation("dead", true)
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
		inst.fixtask = inst:DoTaskInTime(1, FixChester)
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

    inst:AddTag("bigdaddy_eyebone")
    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

	inst.AnimState:SetBank("daddysbone")
	inst.AnimState:SetBuild("daddys_bone")
	inst.AnimState:PlayAnimation("idle_loop", true)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.entity:SetPristine()
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/eyeboneinventory.xml"

	inst:AddComponent("leader")

	inst.openEye = "daddybonealive" -- to daddys_bone when you make the inventoryimage
	inst.closedEye = "daddybonedead" -- to daddys_bone_closed when you make the inventoryimage

	inst.isOpenEye = nil
	OpenEye(inst)

	MakeHauntableLaunch(inst)

	inst.OnLoad = OnLoad
	inst.OnSave = OnSave

	inst.fixtask = inst:DoTaskInTime(1, FixChester)

	return inst
end

return Prefab("common/inventory/bigdaddy_eyebone", fn, assets)
