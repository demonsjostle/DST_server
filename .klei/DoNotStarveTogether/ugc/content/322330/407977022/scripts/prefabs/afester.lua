require "prefabutil"
local brain = require "brains/afesterbrain"
local spibrain = require "brains/afestermorphbrain"
require "stategraphs/SGafester"
require "stategraphs/SGafestermorph"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =
{
    Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ANIM", "anim/afester.zip"),
    Asset("ANIM", "anim/sluster.zip"),
    Asset("ANIM", "anim/spister.zip"),
    Asset("ANIM", "anim/spitster.zip"),
    Asset("SOUND", "sound/chester.fsb"),
}

local prefabs =
{
    "afestertoy",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function OnAttacked(inst, data)
    local attacker = data.attacker
    inst.components.combat:SetTarget(attacker)
end

local function FindTargets(guy)
	return guy:HasTag("monster")
       and inst.components.combat:CanTarget(guy)
       and not (inst.components.follower and inst.components.follower.leader == guy)
end

local function KeepTargetFn(inst, target)
   return target
          and target.components.combat
          and target.components.health
          and not target.components.health:IsDead()
          and not (inst.components.follower and inst.components.follower.leader == target)
end

	
local function Retarget(inst)
    return FindEntity(inst, TUNING.WALRUS_TARGET_DIST, function(guy) 
        return inst.components.combat:CanTarget(guy)
    end,
    nil,
    {"player","spiderden"},
    {"tallbird","walrus","monster","spat","werepig","berrythief","mosquito","monkey","snurtle","slurtle","merm","hostile"}
    )
end

local function SpitRetarget(inst)
    return FindEntity(inst, TUNING.WALRUS_TARGET_DIST, function(guy) 
        return inst.components.combat:CanTarget(guy)
    end,
    nil,
    {"player","spiderden"},
    {"tallbird","walrus","monster","spat","werepig","berrythief","mosquito","monkey","snurtle","slurtle","merm","hostile"}
    )
end

local function WeaponDropped(inst)
    inst:Remove()
end

local function MakeWeapon(inst)
    if inst.components.inventory then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        MakeInventoryPhysics(weapon)
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(TUNING.SPIDER_SPITTER_DAMAGE_RANGED)
        weapon.components.weapon:SetRange(20, 25)
        weapon.components.weapon:SetProjectile("spider_web_spit")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(function() WeaponDropped(weapon) end)
        weapon:AddComponent("equippable")
        inst.weapon = weapon
        inst.components.inventory:Equip(inst.weapon)
        inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
    end
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
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    inst:AddTag("companion")
end

local function turnlightoff(inst, light)
    inst.SoundEmitter:KillSound("idlesound")
    if light then
        light:Enable(false)
    end
end

local function MorphSpister(inst)
    inst.AnimState:SetBank("spister")
    inst.AnimState:SetBuild("spister")
	
    inst:AddTag("spister")
	
    inst.components.container:WidgetSetup("chester")

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_HIDER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_HIDER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetTarget(nil)
	
    inst:SetBrain(spibrain)

    inst:ListenForEvent("attacked", OnAttacked)
	
    local leader = inst.components.follower.leader    
    if leader ~= nil then
        inst.components.follower.leader:MorphSpistertoy()
    end

    inst.AfesterState = "SPISTER"
    inst._issluster:set(false)
    inst:SetStateGraph("SGafestermorph")
	
    inst.components.container.canbeopened = true
end

local function MorphSluster(inst)
    inst.AnimState:SetBank("sluster")
    inst.AnimState:SetBuild("sluster")

    inst:AddTag("sluster")
	
    inst.components.container:WidgetSetup("shadowchester")
	
    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphSlustertoy()
    end
	
    if not TheWorld.ismastersim then
        return inst
    end
	
        inst:AddComponent("lighttweener")
        local light = inst.entity:AddLight()

        inst.Light:Enable(false)
        inst.Light:SetColour(223/255, 208/255, 69/255)
		inst.Light:SetRadius(2)
        inst.Light:SetIntensity(.8)
        inst.Light:SetFalloff(.33)

    	inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(3, 7 )
        inst.components.playerprox:SetOnPlayerNear(function() inst.components.lighttweener:StartTween(nil, 5, nil, nil, nil, 0.5) light:Enable(true) end)
        inst.components.playerprox:SetOnPlayerFar(function() inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, 1) light:Enable(false) end)
	
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
	
    inst.AfesterState = "SLUSTER"
    inst._issluster:set(true)
end


local function MorphSpitster(inst)
    inst.AnimState:SetBank("spitster")
    inst.AnimState:SetBuild("spitster")
	
    inst:AddTag("spitster")
	
    inst.components.container:WidgetSetup("chester")

    inst:SetBrain(spibrain)
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventory")

    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_SPITTER_DAMAGE_MELEE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_SPITTER_ATTACK_PERIOD + math.random()*2)
    inst.components.combat:SetRange(TUNING.SPIDER_SPITTER_ATTACK_RANGE, TUNING.SPIDER_SPITTER_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(2, SpitRetarget)
    inst.components.combat:SetTarget(nil)

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
	
    inst:SetBrain(spibrain)
	
    inst:ListenForEvent("attacked", OnAttacked)
	
    local leader = inst.components.follower.leader    
    if leader ~= nil then
        inst.components.follower.leader:MorphSpitstertoy()
    end
	
    inst.AfesterState = "SPITSTER"
    inst._issluster:set(false)
    inst:SetStateGraph("SGafestermorph")
    inst.components.container.canbeopened = true
    MakeWeapon(inst)
end


local function CanMorph(inst)
    if not TheWorld.state.isnight or inst.AfesterState ~= "AFESTER" then
        return false, false, false
    end

    local container = inst.components.container
    if container:IsOpen() then
        return false, false, false
    end

    local canspister = true
    local cansluster = true
    local canspitster = true

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item == nil then
            return false, false, false
        end

        canspister = canspister and item.prefab == "monstermeat"
        cansluster = cansluster and item.prefab == "lightbulb"
        canspitster = canspitster and item.prefab == "spidereggsack"

        if not (canspister or cansluster or canspitster) then
            return false, false, false
        end
    end

    return canspister, cansluster, canspitster
end

local function CheckForMorph(inst)
    local canspister, cansluster, canspitster = CanMorph(inst)
    if canspister or cansluster or canspitster then
        inst.sg:GoToState("pretrans")
    end
end

local function DoMorph(inst, fn)
    inst.MorphAfester = nil
    inst:StopWatchingWorldState("startnight", CheckForMorph)
    inst:RemoveEventCallback("onclose", CheckForMorph)
    fn(inst)
end

local function MorphAfester(inst)
    local canspister, cansluster, canspitster = CanMorph(inst)
    if canspister then
        if not (canspister or cansluster or canspitster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphSpister)
	elseif cansluster then
        if not (canspister or cansluster or canspitster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphSluster)
	elseif canspitster then
        if not (canspister or cansluster or canspitster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphSpitster)
	end
end

local function OnSave(inst, data)
    data.AfesterState = inst.AfesterState
end


local function OnPreLoad(inst, data)
    if data == nil then
        return
    elseif data.AfesterState == "SPISTER" then
        DoMorph(inst, MorphSpister)
    elseif data.AfesterState == "SLUSTER" then
        DoMorph(inst, MorphSluster)
    elseif data.AfesterState == "SPITSTER" then
        DoMorph(inst, MorphSpitster)
    end
end

local function OnIsSlusterDirty(inst)
    if inst._issluster:value() ~= inst._clientslustermorphed then
        inst._clientslustermorphed = inst._issluster:value()
        inst.replica.container:WidgetSetup(inst._clientslustermorphed and "shadowchester" or nil)
    end
end


local function GetStatus(inst)
    if inst:HasTag("spister") then
        return "Shellster"
    elseif inst:HasTag("sluster") then
        return "Fluffy"
    elseif inst:HasTag("afester") then
        return "Afester"
    elseif inst:HasTag("spitster") then
        return "Webster"
    end
end

local function create_afester()

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
    inst:AddTag("afester")
    inst:AddTag("notraptrigger")
	inst:AddTag("noauradamage")

    inst.MiniMapEntity:SetIcon("afester.tex")

    inst.AnimState:SetBank("afester")
    inst.AnimState:SetBuild("afester")

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

    inst._issluster = net_bool(inst.GUID, "_issluster", "onisslusterdirty")

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
        inst.replica.container:WidgetSetup("chester")
        end)
        inst._clientslustermorphed = false
        inst:ListenForEvent("onisslusterdirty", OnIsSlusterDirty)
        return inst
    end

    inst.entity:SetPristine()

    ------------------------------------------

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.runspeed = 10
	inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "chester_body")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("chester")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose

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

    inst:SetStateGraph("SGafester")
    inst.sg:GoToState("idle")

    inst:SetBrain(brain)

    inst.AfesterState = "AFESTER"
    inst.MorphAfester = MorphAfester
    inst:WatchWorldState("startnight", CheckForMorph)
    inst:ListenForEvent("onclose", CheckForMorph)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("common/afester", create_afester, assets, prefabs)

