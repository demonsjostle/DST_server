
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "ANIM", "anim/daisy.zip" ),
Asset( "ANIM", "anim/daisy_pig.zip" ),
Asset( "ANIM", "anim/daisy_moon.zip" ),
}
local prefabs = {}

-- Custom starting items
local start_inv = {	"daisyhat",
	}


local function daisyform(inst)

    if inst.strength == "fullpig" then 
	inst:RemoveTag("weredaisy")		
	inst:RemoveTag("insomniac")	
	inst:AddTag("scarytoprey")		

    inst.AnimState:SetBuild("daisy")
	inst.components.talker:Say("Oink!", 2.5,true)	
	inst.SoundEmitter:PlaySound("dontstarve/pig/oink")	
		local x, y, z = inst.Transform:GetWorldPosition()
		local fx = SpawnPrefab("maxwell_smoke")
		fx.Transform:SetPosition(x, y, z)
		SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
		
	inst.components.eater.ignoresspoilage = false				
	inst.components.eater.strongstomach = false
	inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 1.3)
	inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 1.3)	
	inst.components.hunger.hungerrate = 0.5 * TUNING.WILSON_HUNGER_RATE					
	inst.components.combat.damagemultiplier = 0.8	
	inst.components.sanity.dapperness = 0
	
    elseif inst.strength == "hungrypig" then
	inst:RemoveTag("weredaisy")
	inst:RemoveTag("insomniac")	
	inst:RemoveTag("scarytoprey")		
	
	inst.AnimState:SetBuild("daisy_pig")
    inst.SoundEmitter:PlaySound("dontstarve/pig/oink")		
		local x, y, z = inst.Transform:GetWorldPosition()
		local fx = SpawnPrefab("maxwell_smoke")
		fx.Transform:SetPosition(x, y, z)
		SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())	
		
	inst.components.eater.ignoresspoilage = true
	inst.components.eater.strongstomach = true		
	inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 0.98)
	inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 0.98)				
	inst.components.hunger.hungerrate = 1.7 * TUNING.WILSON_HUNGER_RATE
	inst.components.combat.damagemultiplier = 1
	inst.components.sanity.dapperness = 0
	
    elseif inst.strength == "moondaisy" then
	
        inst.AnimState:SetBuild("daisy_moon")
		
		local x, y, z = inst.Transform:GetWorldPosition()
		local fx = SpawnPrefab("maxwell_smoke")
		fx.Transform:SetPosition(x, y, z)
		SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())	
		inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/grunt")					
		inst:AddTag("weredaisy")		
		inst:AddTag("insomniac")
		inst:AddTag("scarytoprey")		

		inst.components.eater.ignoresspoilage = true
		inst.components.eater.strongstomach = true		
	    inst.components.combat.damagemultiplier = 3
		inst.components.hunger.hungerrate = 2 * TUNING.WILSON_HUNGER_RATE
		inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 1.6)
		inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 1.6)
		inst.components.sanity.dapperness = TUNING.DAPPERNESS_LARGE * (-1)	
 
	end
end


local function piggychange(inst, phase)

    if inst:HasTag("playerghost") or
        inst.components.health:IsDead() then
        return
    end

    if inst.strength == "hungrypig" then
            if inst.components.hunger.current > 150 then
			inst.strength = "fullpig"			
			daisyform(inst)
            end
    end
	
    if inst.strength == "fullpig" then
            if inst.components.hunger.current < 150 then
			inst.strength = "hungrypig"		
			daisyform(inst)
            end
    end
	
	
end


local function daisyeat(inst, data)
    if inst.strength == "fullpig" or
        inst:HasTag("weredaisy") then
        return
    end
	
	if data.food.components.edible.foodtype == "VEGGIE" then 
	
	local x, y, z = inst.Transform:GetWorldPosition()	
	inst.daisypooping = true
	inst.AnimState:PlayAnimation("emote_pre_sit3")
	inst.SoundEmitter:PlaySound("dontstarve/beefalo/fart")
	inst:DoTaskInTime(.4, function() inst.AnimState:PlayAnimation("emote_loop_sit3") end)	
	inst:DoTaskInTime(.8, function() 
		SpawnPrefab("poop").Transform:SetPosition(x, y, z)
		inst.SoundEmitter:PlaySound("dontstarve/beefalo/fart") 
	end)
	end
	
	if data.food.prefab == "monstermeat" then 
	inst:DoTaskInTime(0, function()         
	inst.AnimState:SetBuild("daisy_moon")
		
		local x, y, z = inst.Transform:GetWorldPosition()
		local fx = SpawnPrefab("maxwell_smoke")
		fx.Transform:SetPosition(x, y, z)
		SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())	
		inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/grunt")					
		inst:AddTag("weredaisy")		
		inst:AddTag("insomniac")
		inst:AddTag("scarytoprey")		

		inst.components.eater.ignoresspoilage = false
		inst.components.eater.strongstomach = false		
	    inst.components.combat.damagemultiplier = 2
		inst.components.hunger.hungerrate = 3 * TUNING.WILSON_HUNGER_RATE
		inst.components.locomotor.walkspeed = (TUNING.WILSON_WALK_SPEED * 1.6)
		inst.components.locomotor.runspeed = (TUNING.WILSON_RUN_SPEED * 1.6)
		inst.components.sanity.dapperness = TUNING.DAPPERNESS_LARGE * (-2)		end)
	inst:DoTaskInTime(60, function() inst.strength = "hungrypig" 	daisyform(inst)	
	piggychange(inst)	end )


	end
	
	
end


local function OnPigMoon(inst, isfullmoon)

	if isfullmoon then
	inst.strength = "moondaisy"		
		daisyform(inst)	
		piggychange(inst)		
	else 		
		inst.strength = "hungrypig"		
		daisyform(inst)		
		piggychange(inst)

	end 
end
 


local function onbecamehuman(inst)
	-- Set speed when reviving from ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "daisy_speed_mod")
    inst.strength = "hungrypig"	
	inst:ListenForEvent("hungerdelta", piggychange)
    piggychange(inst, nil, true)	
	daisyform(inst)			
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "daisy_speed_mod")

   inst:RemoveEventCallback("hungerdelta", piggychange)
end


-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
	

end
-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "daisy.tex" )
	inst:AddTag("daisy") 
	inst:AddTag("pigprincess")
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- choose which sounds this character will play
	inst.soundsname = "wendy"
	inst.strength = "hungrypig"	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	inst:AddTag("hungrypig")	
	-- Stats	
	inst.components.health:SetMaxHealth(100)
	inst.components.hunger:SetMax(300)
	inst.components.sanity:SetMax(150)
	
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
	inst:ListenForEvent("oneat", daisyeat)
	inst:WatchWorldState("isfullmoon", OnPigMoon)
    inst:WatchWorldState("phase", piggychange)
	OnPigMoon(inst, TheWorld.state.isfullmoon)	
	
end

return MakePlayerCharacter("daisy", prefabs, assets, common_postinit, master_postinit, start_inv)
