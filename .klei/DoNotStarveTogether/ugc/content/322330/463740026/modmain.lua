PrefabFiles = {
	"personal_chester",
	"personal_chester_eyebone",
}

local require = GLOBAL.require

-- Ownership
local ownership = GetModConfigData("ownership")
local ownershiptag = 'uid_private'

-- Function to turn regular chester into personal
local function MakeChesterPersonal(inst)
	inst:RemoveTag("chester")
	inst:AddTag("_named")
	inst:AddComponent("named")
	inst.persists = false
end

-- Chester Eyebone Functions
local function OpenEye(inst)
    if not inst.isOpenEye then
        inst.isOpenEye = true
        inst.components.inventoryitem:ChangeImageName(inst.openEye)
        inst.AnimState:PlayAnimation("idle_loop", true)
    end
end

local function CloseEye(inst)
    if inst.isOpenEye then
        inst.isOpenEye = nil
        inst.components.inventoryitem:ChangeImageName(inst.closedEye)
        inst.AnimState:PlayAnimation("dead", true)
    end
end

local SPAWN_DIST = 30
local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * GLOBAL.PI
    local radius = SPAWN_DIST
    local offset = GLOBAL.FindWalkableOffset(pt, theta, radius, 12, true)
    return offset ~= nil and (pt + offset) or nil
end

local function SpawnChester(inst)
	if not inst.owner then
		print("Error: Eyebone has no linked player!")
		return
	end

    local pt = inst:GetPosition()
        
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
		local chester = GLOBAL.SpawnPrefab("chester")
        if chester ~= nil then
            chester.Physics:Teleport(spawn_pt:Get())
            chester:FacePoint(pt:Get())
			if inst.owner then
				inst.owner.chester = chester
				MakeChesterPersonal(chester)
			else
				print("There was an error linking personal chester")
				chester:Remove()
				return;
			end
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
    chester = chester or (inst.owner and inst.owner.chester)
    if chester ~= nil then
		if inst.owner and chester.components.named then
			chester.components.named:SetName(inst.owner.name.."'s Chester")
			if inst.ownership then
				chester:AddTag(ownershiptag)
				chester:AddTag("uid_" .. inst.owner.userid)
			end
		end
        OpenEye(inst)
        inst:ListenForEvent("death", function()
			if inst.owner then
				inst.owner.chester = nil
			end
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
    RebindChester(inst, (inst.owner and inst.owner.chester) or SpawnChester(inst))
end
StartRespawn = function(inst, time)
    StopRespawn(inst)

    time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnChester)
    inst.respawntime = GLOBAL.GetTime() + time
    CloseEye(inst)
end

local function FixChester(inst)
    inst.fixtask = nil
    --take an existing chester if there is one
    if not RebindChester(inst) then
        CloseEye(inst)
        
        if inst.components.inventoryitem.owner ~= nil then
            local time_remaining = inst.respawntime ~= nil and math.max(0, inst.respawntime - GLOBAL.GetTime()) or 0
            StartRespawn(inst, time_remaining)
        end
    end
end
local function OnPutInInventory(inst)
    if inst.fixtask == nil then
        inst.fixtask = inst:DoTaskInTime(1, FixChester)
    end
end

local function MakeEyebonePersonal(inst)
	inst:AddTag("_named")
	inst:AddComponent("named")
	inst.components.named:SetName(inst.owner.name.."'s Eye Bone")
	inst.persists = false
	-- Override eyebone's binding code
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	if inst.fixtask then
		inst.fixtask:Cancel()
		inst.fixtask = inst:DoTaskInTime(1, FixChester)
	end
end

-- An eyebone is given every time player is spawned/loaded. It does not persist
local function GiveEyebone(inst)
	local eyebone = GLOBAL.SpawnPrefab("chester_eyebone")
	if eyebone then
		eyebone.owner = inst
		MakeEyebonePersonal(eyebone)
		inst.eyebone = eyebone
		inst.components.inventory.ignoresound = true
		inst.components.inventory:GiveItem(eyebone)
		inst.components.inventory.ignoresound = false
		eyebone.ownership = ownership
		return eyebone
	end
end
local function PersonalChester(inst)
	if not GLOBAL.TheWorld.ismastersim or inst:HasTag("specialchesterowner") then
		return
	end

	local OnDespawn_prev = inst.OnDespawn
	local OnDespawn_new = function(inst, ...)
		-- Remove chester
		if inst.chester then
			if inst.chester.components.container then
				-- Don't allow chester to despawn with irreplaceable items
				inst.chester.components.container:DropEverythingWithTag("irreplaceable")
			end
			
			-- We need time to save before despawning.
			inst.chester:DoTaskInTime(0, function(inst)
				if inst and inst:IsValid() then
					inst:Remove()
				end
			end)
			
		end
		
		if inst.eyebone then
			-- Eyebone drops from whatever its in
			local owner = inst.eyebone.components.inventoryitem.owner
			if owner then
				-- Remember if eyebone is held
				if owner == inst or (owner.components.inventoryitem and owner.components.inventoryitem.owner == inst) then
					inst.eyebone.isheld = true
				else
					inst.eyebone.isheld = false
				end
				if owner.components.container then
					owner.components.container:DropItem(inst.eyebone)
				elseif owner.components.inventory then
					owner.components.inventory:DropItem(inst.eyebone)
				end
			end
			-- Remove eyebone
			inst.eyebone:DoTaskInTime(0.1, function(inst)
				if inst and inst:IsValid() then
					inst:Remove()
				end
			end)
		else
			print("Error: Player has no linked eyebone!")
		end
		if OnDespawn_prev then
			return OnDespawn_prev(inst, ...)
		end
	end
	inst.OnDespawn = OnDespawn_new
	
	local OnSave_prev = inst.OnSave
	local OnSave_new = function(inst, data, ...)
		local references = OnSave_prev(inst, data, ...)
		if inst.chester then
			-- Save chester
			local refs = {}
			if not references then
				references = {}
			end
			data.chester, refs = inst.chester:GetSaveRecord()
			if refs then
				for k,v in pairs(refs) do
					table.insert(references, v)
				end 
			end				
		end
		if inst.eyebone then
			-- Save eyebone
			local refs = {}
			if not references then
				references = {}
			end
			data.eyebone, refs = inst.eyebone:GetSaveRecord()
			if refs then
				for k,v in pairs(refs) do
					table.insert(references, v)
				end 
			end
			-- Remember if was holding eyebone
			if inst.eyebone.isheld then
				data.holdingeyebone = true
			else
				data.holdingeyebone = false
			end
		end
		return references
	end
    inst.OnSave = OnSave_new
	
	local OnLoad_prev = inst.OnLoad
	local OnLoad_new = function(inst, data, ...)
		if data.chester ~= nil then
			-- Load chester
			inst.chester = GLOBAL.SpawnSaveRecord(data.chester)
			MakeChesterPersonal(inst.chester)
		--else
			--print("Warning: No chester was loaded from save file!")
		end
		
		if data.eyebone ~= nil then
			-- Load eyebone
			inst.eyebone = GLOBAL.SpawnSaveRecord(data.eyebone)
			inst.eyebone.owner = inst
			inst.eyebone.ownership = ownership
			MakeEyebonePersonal(inst.eyebone)
			
			-- Look for eyebone at spawn point and re-equip
			inst:DoTaskInTime(0, function(inst)
				--[[
				if data.holdingeyebone or (inst.eyebone and inst:IsNear(inst.eyebone,4)) then
					inst:ReturnEyebone()
				end
				]]
				-- TEMPORARY FIX until I find a solution
				inst:ReturnEyebone()
			end)
		else
			print("Warning: No eyebone was loaded from save file!")
		end
		
		-- Create new eyebone if none loaded
		if not inst.eyebone then
			GiveEyebone(inst)
		end
		
		if OnLoad_prev then
			return OnLoad_prev(inst, data, ...)
		end
	end
    inst.OnLoad = OnLoad_new
	
	local OnNewSpawn_prev = inst.OnNewSpawn
	local OnNewSpawn_new = function(inst, ...)
		-- Give new eyebone. Let chester spawn naturally.
		GiveEyebone(inst)
		if OnNewSpawn_prev then
			return OnNewSpawn_prev(inst, ...)
		end
	end
    inst.OnNewSpawn = OnNewSpawn_new
	
	inst:ListenForEvent("ms_playerreroll", function(inst)
		if inst.chester and inst.chester.components.container then
			inst.chester.components.container:DropEverything()
		end
	end)
	
	if GLOBAL.TheNet:GetServerGameMode() == "wilderness" then
		local function ondeath(inst, data)
			-- Kill player's chester in wilderness mode :(
			if inst.chester then
				inst.chester.components.health:Kill()
			end
			if inst.eyebone then
				inst.eyebone:Remove()
			end
		end
		inst:ListenForEvent("death", ondeath)
	end
	
	-- Debug function to return eyebone
	inst.ReturnEyebone = function()
		if inst.eyebone and inst.eyebone:IsValid() then
			if inst.eyebone.components.inventoryitem.owner ~= inst then
				inst.components.inventory:GiveItem(inst.eyebone)
			end
		else
			GiveEyebone(inst)
		end
		if inst.chester and not inst:IsNear(inst.chester, 20) then
			local pt = inst:GetPosition()
			local spawn_pt = GetSpawnPoint(pt)
			if spawn_pt ~= nil then
				inst.chester.Physics:Teleport(spawn_pt:Get())
				inst.chester:FacePoint(pt:Get())
			end
		end
	end
end
local doReturnEyebone = function(target)
	if not target or not target.ReturnEyebone then 
		print("Error: Cannot return eyebone")
		return 
	end
	target:ReturnEyebone()
end
GLOBAL.c_returneyebone = function(inst)
	if type(inst) == "string" then
		local foundplayer = false
		for _, v in ipairs(GLOBAL.AllPlayers) do
			if v.name == inst or v.userid == inst then
				foundplayer = true;
				doReturnEyebone(v)
				break;
			end
		end
		if not foundplayer then
			print("Error: No match")
		end
		return
	end
	if not inst then
		inst = GLOBAL.ConsoleCommandPlayer()
	end
	if not inst or not inst.ReturnEyebone then 
		print("Error: Cannot return eyebone")
		return 
	end
	doReturnEyebone(inst)
end

AddPlayerPostInit(PersonalChester)

-- Convert legacy prefabs
AddPrefabPostInit("personal_chester_eyebone", function(inst)
	inst.prefab = "chester_eyebone"
end)
AddPrefabPostInit("personal_chester", function(inst)
	inst.prefab = "chester"
end)