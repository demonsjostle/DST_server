require "prefabutil"
local brain = require "brains/bluechesterbrain"
require "stategraphs/SGbluechester"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =
{
    Asset("ANIM", "anim/ui_bluechester_shadow_3x4.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),

    Asset("ANIM", "anim/bluechester.zip"),
    Asset("ANIM", "anim/bluechester_build.zip"),
    Asset("ANIM", "anim/bluechester_shadow_build.zip"),
    Asset("ANIM", "anim/bluechester_snow_build.zip"),

    Asset("SOUND", "sound/chester.fsb"),
}

local prefabs =
{
    "bluechester_eyebone",
}

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function ShouldKeepTarget()
    return false -- chester can't attack, and won't sleep if he has a target
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

-- eye bone was killed/destroyed
local function OnStopFollowing(inst)
    --print("chester - OnStopFollowing")
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    --print("chester - OnStartFollowing")
    inst:AddTag("companion")
end

-- PERISH FUNCTIONS
local function onitemget( inst, data )
    if data.item and data.item.components.perishable then
        data.item.components.perishable:StopPerishing()
    end
end
 
local function onitemlose( inst, data )
    local item = inst.components.container:GetItemInSlot( data.slot )
    if item and item.components.perishable then
        item.components.perishable:StartPerishing()
    end
end

-- END PERISH FUNCTIONS

local function MorphBlueShadowChester(inst)
    inst.AnimState:SetBuild("bluechester_shadow_build")
	inst:AddTag("fridge")

    inst.components.container:WidgetSetup("shadowchester")

    local leader = inst.components.follower.leader    
    if leader ~= nil then
        inst.components.follower.leader:MorphBlueShadowEyebone()
    end

    inst.BlueChesterState = "BLUESHADOW"
    inst._isblueshadowchester:set(true)

	inst:RemoveEventCallback("itemget", onitemget)
	inst:RemoveEventCallback("itemlose", onitemlose)
end

local function MorphBlueSnowChester(inst)
    inst.AnimState:SetBuild("bluechester_snow_build")
    inst:AddTag("fridge")
	
	inst.components.container:WidgetSetup("chester")

    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphBlueSnowEyebone()
    end

    inst.BlueChesterState = "BLUESNOW"
    inst._isblueshadowchester:set(false)

	inst:ListenForEvent( "itemget", onitemget)
	inst:ListenForEvent( "itemlose", onitemlose)
end

--[[
local function MorphNormalChester(inst)
    inst.AnimState:SetBuild("chester_build")
    inst:RemoveTag("fridge")
    inst:RemoveTag("spoiler")

    inst.components.container:WidgetSetup("chester")

    local leader = inst.components.follower.leader    
    if leader ~= nil then
        inst.components.follower.leader:MorphNormalEyebone()
    end

    inst.ChesterState = "NORMAL"
    inst._isshadowchester:set(false)

	inst:RemoveEventCallback("itemget", onitemget)
	inst:RemoveEventCallback("itemlose", onitemlose)
end
--]]

local function CanbMorph(inst)
    if not TheWorld.state.isnight or inst.BlueChesterState ~= "BLUENORMAL" then
        return false, false
    end

    local container = inst.components.container
    if container:IsOpen() then
        return false, false
    end

    local canBlueShadow = true
    local canBlueSnow = true

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item == nil then
            return false, false
        end

        canBlueShadow = canBlueShadow and item.prefab == "nightmarefuel"
        canBlueSnow = canBlueSnow and item.prefab == "bluegem"

        if not (canBlueShadow or canBlueSnow) then
            return false, false
        end
    end

    return canBlueShadow, canBlueSnow
end

local function CheckForbMorph(inst)
    local canBlueShadow, canBlueSnow = CanbMorph(inst)
    if canBlueShadow or canBlueSnow then
        inst.sg:GoToState("transition")
    end
end

local function DobMorph(inst, fn)
    inst.MorphBlueChester = nil
    inst:StopWatchingWorldState("startnight", CheckForbMorph)
    inst:RemoveEventCallback("onclose", CheckForbMorph)
    fn(inst)
end

local function MorphBlueChester(inst)
    local canBlueShadow, canBlueSnow = CanbMorph(inst)
    if not (canBlueShadow or canBlueSnow) then
        return
    end

    local container = inst.components.container
    for i = 1, container:GetNumSlots() do
        container:RemoveItem(container:GetItemInSlot(i)):Remove()
    end

    DobMorph(inst, canBlueShadow and MorphBlueShadowChester or MorphBlueSnowChester)
end

local function OnSave(inst, data)
    data.BlueChesterState = inst.BlueChesterState
end

local function OnPreLoad(inst, data)
    if data == nil then
        return
    elseif data.BlueChesterState == "BLUESHADOW" then
        DobMorph(inst, MorphBlueShadowChester)
    elseif data.BlueChesterState == "BLUESNOW" then
        DobMorph(inst, MorphBlueSnowChester)
    end
end

local function Onisshadowchesterdirty(inst)
    if inst._isblueshadowchester:value() ~= inst._clientblueshadowmorphed then
        inst._clientblueshadowmorphed = inst._isblueshadowchester:value()
        inst.replica.container:WidgetSetup(inst._clientblueshadowmorphed and "shadowchester" or nil)
    end
end

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function create_bluechester()
    --print("chester - create_chester")

    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 75, .5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("bluechester")
    inst:AddTag("notraptrigger")

    inst.MiniMapEntity:SetIcon("chester.png")
    inst.MiniMapEntity:SetCanUseCache(false)

    inst.AnimState:SetBank("bluechester")
    inst.AnimState:SetBuild("bluechester_build")
	inst:AddTag("fridge")
	
	    local light = inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(0/0,0/0,255/255)    

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

    inst._isblueshadowchester = net_bool(inst.GUID, "_isblueshadowchester", "onisshadowchesterdirty")

 if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, function()
		inst.replica.container:WidgetSetup("chester")
	end)
    inst._clientshadowmorphed = false
    inst:ListenForEvent("onisshadowchesterdirty", Onisshadowchesterdirty)
    return inst
end

    inst.entity:SetPristine()

    ------------------------------------------

    --print("   combat")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    --inst:ListenForEvent("attacked", OnAttacked)

    --print("   health")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
    inst:AddTag("noauradamage")


    --print("   inspectable")
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
    --inst.components.inspectable.getstatus = GetStatus

    --print("   locomotor")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7

    --print("   follower")
    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    --print("   knownlocations")
    inst:AddComponent("knownlocations")

    --print("   burnable")
    MakeSmallBurnableCharacter(inst, "chester_body")
    
    --("   container")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("chester")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose

    --print("   sleeper")
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

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

    --print("   sg")
    inst:SetStateGraph("SGbluechester")
    inst.sg:GoToState("idle")

    --print("   brain")
    inst:SetBrain(brain)

    inst.BlueChesterState = "BLUENORMAL"
    inst.MorphBlueChester = MorphBlueChester
    inst:WatchWorldState("startnight", CheckForbMorph)
    inst:ListenForEvent("onclose", CheckForbMorph)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    --print("chester - create_chester END")
    return inst
		end

return Prefab("common/bluechester", create_bluechester, assets, prefabs)