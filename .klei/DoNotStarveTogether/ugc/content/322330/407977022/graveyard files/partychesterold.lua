require "prefabutil"
local brain = require "brains/bluechesterbrain"
require "stategraphs/SGpartychester"
require "components/combat"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =
{
    Asset("ANIM", "anim/armorster.zip"),
    Asset("ANIM", "anim/cookfoodster.zip"),
    Asset("ANIM", "anim/partychester.zip"),
    Asset("ANIM", "anim/rawster.zip"),
    Asset("ANIM", "anim/weaponster.zip"),
    Asset("ANIM", "anim/gemster.zip"),

    Asset("SOUND", "sound/chester.fsb"),
}

local prefabs =
{
    "partybone",
}

SetSharedLootTable( 'rawfood',
{
    {'twigs', 1.0},
    {'twigs', 1.0},
    {'twigs', 1.0},
    {'twigs', 1.0},
    {'berries', 1.0},
    {'carrot', 1.0},
    {'fish', 1.0},
    {'lightbulb', 1.0},
    {'lightbulb', 1.0},
    {'lightbulb', 1.0},
    {'meat', 0.1},
    {'meat', 0.1},
    {'meat', 0.1},
    {'monstermeat', 0.2},
    {'monstermeat', 0.2},
    {'smallmeat', 0.2},
    {'froglegs', 0.2},
    {'hambat', 0.01},
    {'honey', 0.2},
    {'drumstick', 0.1},
    {'drumstick', 0.1},
    {'batwing', 0.1},
    {'green_cap', 0.5},
    {'blue_cap', 0.5},
    {'tallbirdegg', 0.1},
    {'corn', 0.3},
    {'pumpkin', 0.3},
    {'pomegranate', 0.3},
    {'eggplant', 0.3},
    {'durian', 0.3},
    {'fishingrod', 0.5},
    {'bird_egg', 0.2},
    {'dragonfruit', 0.1},
})

SetSharedLootTable( 'armor',
{
    {'beehat', 0.2},
    {'armorgrass', 0.2},
    {'lightbulb', 0.2},
    {'armorwood', 0.2},
    {'beefalohat', 0.4},
    {'featherhat', 0.2},
    {'armor_sanity', 0.2},
    {'sewing_kit', 0.5},
    {'footballhat', 0.2},
    {'silk', 0.6},
    {'silk', 0.6},
    {'strawhat', 0.2},
    {'trunkvest_winter', 0.1},
    {'trunkvest_summer', 0.1},
    {'armormarble', 0.1},
    {'armorsnurtleshell', 0.1},
    {'telestaff', 0.1},
})

SetSharedLootTable( 'cookfood',
{
    {'bird_egg_cooked', 0.2},
    {'fish_cooked', 0.2},
    {'honey', .03},
    {'lightbulb', 0.2},
    {'waffles', 0.2},
    {'waffles', 0.2},
    {'meatballs', 0.1},
    {'taffy', 0.2},
    {'taffy', 0.2},
    {'taffy', 0.2},
    {'dragonfruit_cooked', 0.2},
    {'durian_cooked', 0.2},
    {'eggplant_cooked', 0.2},
    {'pomegranate_cooked', 0.2},
    {'pumpkin_cooked', 0.2},
    {'berries_cooked', 0.2},
    {'corn_cooked', 0.2},
    {'carrot_cooked', 0.2},
    {'tallbirdegg_cooked', 0.2},
    {'seeds_cooked', 0.2},
    {'mandrakesoup', 0.2},
    {'baconeggs', 0.2},
    {'bonestew', 0.2},
    {'kabobs', 0.2},
    {'perogies', 0.2},
    {'butterflymuffin', 0.2},
    {'fishtacos', 0.2},
    {'jammypreserves', 0.2},
    {'fishsticks', 0.2},
    {'turkeydinner', 0.1},
    {'honeynuggets', 0.2},
    {'stuffedeggplant', 0.2},
    {'wetgoop', 0.6},
    {'honeyham', 0.1},
    {'pumpkincookie', 0.2},
    {'frogglebunwich', 0.2},
    {'powcake', 0.2},
    {'fruitmedley', 0.2},
    {'ratatouille', 0.2},
    {'batwing_cooked', 0.2},
    {'drumstick_cooked', 0.1},
    {'meat_dried', 0.2},
    {'cookedmeat', 0.2},
    {'smallmeat_dried', 0.2},
    {'cookedsmallmeat', 0.2},
    {'monstermeat_dried', 0.2},
    {'cookedmonstermeat', 0.2},
    {'froglegs_cooked', 0.2},
    {'dragonpie', 0.01},
})

SetSharedLootTable( 'weapon',
{

    {'gunpowder', 0.3},
    {'spear', 0.5},
    {'shovel', 0.5},
    {'flint', 1.0},
    {'pickaxe', 0.2},
    {'firestaff', 0.1},
    {'hammer', 0.2},
    {'icestaff', 0.1},
    {'pitchfork', 0.1},
    {'nightsword', 0.1},
    {'ruins_bat', 0.1},
    {'goldenshovel', 0.1},
})

SetSharedLootTable( 'gem',
{

    {'bluegem', 0.5},
    {'redgem', 0.5},
    {'lightbulb', 0.5},
    {'gears', 0.05},
    {'goldnugget', 1.0},
    {'greengem', 0.3},
    {'orangegem', 0.3},
    {'yellowgem', 0.3},
    {'purplegem', 0.3},
    {'krampus_sack', 0.01},
    {'heatrock', 0.5},
    {'minerhat', 0.5},
    {'deerclops_eyeball', 0.1},
    {'amulet', 0.5},
    {'goldenaxe', 0.1},
    {'bedroll_furry', 0.1},
})

SetSharedLootTable( 'pooper',
{
    {'poop', 0.1},
})

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
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

local function MorphArmorster(inst)
    inst.AnimState:SetBuild("armorster")
    inst:AddTag("spoiler")

    inst.components.lootdropper:SetChanceLootTable('armor')
	
    local leader = inst.components.follower.leader    
    if leader ~= nil then
        inst.components.follower.leader:MorphArmorsterbone()
    end

    inst.PartyChesterState = "ARMORSTER"
end

local function MorphCookfoodster(inst)
    inst.AnimState:SetBuild("cookfoodster")

    inst.components.lootdropper:SetChanceLootTable('cookfood')
	
    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphCookfoodsterbone()
    end

    inst.PartyChesterState = "COOKFOODSTER"
end

local function MorphRawster(inst)
    inst.AnimState:SetBuild("rawster")
	
    inst.components.lootdropper:SetChanceLootTable('rawfood')
	
    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphRawsterbone()
    end

    inst.PartyChesterState = "RAWSTER"
end

local function MorphWeaponster(inst)
    inst.AnimState:SetBuild("weaponster")

    inst.components.lootdropper:SetChanceLootTable('weapon')

    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphWeaponsterbone()
    end

    inst.PartyChesterState = "WEAPONSTER"
end

local function MorphGemster(inst)
    inst.AnimState:SetBuild("gemster")

    inst.components.lootdropper:SetChanceLootTable('gem')

    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphGemsterbone()
    end

    inst.PartyChesterState = "GEMSTER"
end

local function CanMorph(inst)
    if not TheWorld.state.isnight or inst.PartyChesterState ~= "DUBSTER" then
        return false, false, false, false, false, false
    end

    local container = inst.components.container
    if container:IsOpen() then
        return false, false, false, false, false, false
    end

    local canarmorster = true
    local cancookfoodster = true
    local canrawster = true
    local canweaponster = true
    local cangemster = true

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item == nil then
            return false, false, false, false, false, false
        end

        canarmorster = canarmorster and item.prefab == "livinglog"
        cancookfoodster = cancookfoodster and item.prefab == "wetgoop"
        canrawster = canrawster and item.prefab == "seeds"
        canweaponster = canweaponster and item.prefab == "spear"
        cangemster = cangemster and item.prefab == "papyrus"

        if not (canarmorster or cancookfoodster or canrawster or canweaponster or cangemster) then
            return false, false, false, false, false, false
        end
    end

    return canarmorster, cancookfoodster, canrawster, canweaponster, cangemster
end

local function CheckForMorph(inst)
    local canarmorster, cancookfoodster, canrawster, canweaponster, cangemster = CanMorph(inst)
    if canarmorster or cancookfoodster or canrawster or canweaponster or cangemster then
        inst.sg:GoToState("transition")
    end
end

local function DoMorph(inst, fn)
    inst.MorphPartyChester = nil
    inst:StopWatchingWorldState("startnight", CheckForMorph)
    inst:RemoveEventCallback("onclose", CheckForMorph)
    fn(inst)
end

local function MorphPartyChester(inst)
    local canarmorster, cancookfoodster, canrawster, canweaponster, cangemster = CanMorph(inst)
    if canarmorster then
        if not (canarmorster or cancookfoodster or canrawster or canweaponster or cangemster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphArmorster)
	elseif cancookfoodster then
        if not (canarmorster or cancookfoodster or canrawster or canweaponster or cangemster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphCookfoodster)
	elseif rawster then
        if not (canarmorster or cancookfoodster or canrawster or canweaponster or cangemster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphRawster)
	elseif canweaponster then
        if not (canarmorster or cancookfoodster or canrawster or canweaponster or cangemster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphWeaponster)
	elseif cangemster then
        if not (canarmorster or cancookfoodster or canrawster or canweaponster or cangemster) then return end
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
        DoMorph(inst, MorphGemster)
	end
end

local function OnSave(inst, data)
    data.PartyChesterState = inst.PartyChesterState
end

local function OnPreLoad(inst, data)
    if data == nil then
        return
    elseif data.PartyChesterState == "ARMORSTER" then
        DoMorph(inst, MorphArmorster)
    elseif data.PartyChesterState == "COOKFOODSTER" then
        DoMorph(inst, MorphCookfoodster)
    elseif data.PartyChesterState == "RAWSTER" then
        DoMorph(inst, MorphRawster)
    elseif data.PartyChesterState == "WEAPONSTER" then
        DoMorph(inst, MorphWeaponster)
    elseif data.PartyChesterState == "GEMSTER" then
        DoMorph(inst, MorphGemster)
    end
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function create_partychester()

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
    inst:AddTag("partychester")
    inst:AddTag("notraptrigger")

    inst.AnimState:SetBank("partychester")
    inst.AnimState:SetBuild("partychester")

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
        inst.replica.container:WidgetSetup("chester")
        end)
        return inst
    end
	
    inst.entity:SetPristine()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('pooper')
	
    ------------------------------------------

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
    inst:AddTag("noauradamage")


    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7

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

    inst:SetStateGraph("SGpartychester")
    inst.sg:GoToState("idle")

    inst:SetBrain(brain)

    inst.PartyChesterState = "DUBSTER"
    inst.MorphPartyChester = MorphPartyChester
    inst:WatchWorldState("startnight", CheckForMorph)
    inst:ListenForEvent("onclose", CheckForMorph)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("common/partychester", create_partychester, assets, prefabs)