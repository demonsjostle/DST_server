require "prefabutil"
local brain = require "brains/chesterbrain"
require "stategraphs/SGchester"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets = 
{
    Asset("ANIM", "anim/cavester.zip"),
    Asset("SOUND", "sound/chester.fsb")
}

local prefabs = 
{
    "glowbone"
}

local sounds =
{
    hurt = "dontstarve/creatures/chester/hurt",
    pant = "dontstarve/creatures/chester/pant",
    death = "dontstarve/creatures/chester/death",
    open = "dontstarve/creatures/chester/open",
    close = "dontstarve/creatures/chester/close",
    pop = "dontstarve/creatures/chester/pop",
    boing = "dontstarve/creatures/chester/boing",
    lick = "dontstarve/creatures/chester/lick",
}

local function ShouldWakeUp(inst)
	return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
	return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and 
	inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and 
	not TheWorld.state.isfullmoon
end

local function ShouldKeepTarget()
	return false
end

local function OnOpen(inst)
	if not inst.components.health:IsDead() then
		inst.sg:GoToState("open")
	end
end 

local function OnClose(inst)
	if not inst.components.health:IsDead() and inst.sg.currentstate.name ~= "transition" then
		inst.sg:GoToState("close")
	end
end 

local function OnStopFollowing(inst)
	inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
	inst:AddTag("companion")
end

local function create_cavester()

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeCharacterPhysics(inst, 75, 0.5)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)

	inst:AddTag("companion")
	inst:AddTag("character")
	inst:AddTag("scarytoprey")
	inst:AddTag("cavester")
	inst:AddTag("notraptrigger")
	inst:AddTag("noauradamage")

	inst.MiniMapEntity:SetIcon("chester.png")
	inst.MiniMapEntity:SetCanUseCache(false)

	inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetColour(223/255, 208/255, 69/255)
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(4)
    inst.Light:SetIntensity(.5)
	
	inst.AnimState:SetBank("chester")
	inst.AnimState:SetBuild("cavester")

	inst.DynamicShadow:SetSize(2, 1.5)

	inst.Transform:SetFourFaced()

	if not TheWorld.ismastersim then
		--[[
		inst:DoTaskInTime(0, function()
			inst.replica.container:WidgetSetup("shadowchester")
		end)
		--]]
		return inst
	end
	
	inst.entity:SetPristine()

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "chester_body"
	inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
	
	inst:AddComponent("container")
	inst.components.container:WidgetSetup("shadowchester")
	inst.components.container.onopenfn = OnOpen
	inst.components.container.onclosefn = OnClose
 
    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
	inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
	
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL

	inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	
	inst:AddComponent("knownlocations")

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 6
	inst.components.locomotor.runspeed = 10
	inst.components.locomotor:SetAllowPlatformHopping(true)
 
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")
	
	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(3)
	inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWakeUp)
	
	inst.sounds = sounds

	MakeSmallBurnableCharacter(inst, "chester_body")

	MakeHauntableDropFirstItem(inst)
	AddHauntableCustomReaction(inst, function(inst, haunter)
		if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
			inst.components.hauntable.panic = true
			inst.components.hauntable.panictimer = TUNING.HAUNT_PANIC_TIME_SMALL
			inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
			return true
		end
		return false
	end, false, false, true)

	inst:SetBrain(brain)
	
	inst:SetStateGraph("SGchester")
	inst.sg:GoToState("idle")

	inst:DoPeriodicTask(1, function(inst)
    if TheWorld.state.isnight 
    then
    inst.Light:Enable(true)    
    else
    inst.Light:Enable(false)
    end
end)
	return inst
	
end

return Prefab("common/cavester", create_cavester, assets, prefabs)