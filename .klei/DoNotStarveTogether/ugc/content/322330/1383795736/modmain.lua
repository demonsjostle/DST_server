PrefabFiles = {
	"daisy",
	"daisy_none",
	"daisyhat",
	
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/daisy.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/daisy.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/daisy.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/daisy.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/daisy_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/daisy_silho.xml" ),

    Asset( "IMAGE", "bigportraits/daisy.tex" ),
    Asset( "ATLAS", "bigportraits/daisy.xml" ),
	
	Asset( "IMAGE", "images/map_icons/daisy.tex" ),
	Asset( "ATLAS", "images/map_icons/daisy.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_daisy.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_daisy.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_daisy.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_daisy.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_daisy.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_daisy.xml" ),
	
	Asset( "IMAGE", "images/names_daisy.tex" ),
    Asset( "ATLAS", "images/names_daisy.xml" ),
	
    Asset( "IMAGE", "bigportraits/daisy_none.tex" ),
    Asset( "ATLAS", "bigportraits/daisy_none.xml" ),

}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local resolvefilepath = GLOBAL.resolvefilepath

AddComponentPostInit("follower", function(self)
    local old_AddLoyaltyTime = self.AddLoyaltyTime
    function self:AddLoyaltyTime(time) 
        old_AddLoyaltyTime(self, time)
        if self.leader and self.leader.prefab == "daisy" then
            self.task:Cancel() 
            self.task = nil
        end
    end   

    local old_LongUpdate = self.LongUpdate
    function self:LongUpdate(dt)
        old_LonhUpdate(self, dt)
        if self.leader and self.leader.prefab == "daisy" then
            self.task:Cancel()
            self.task = nil
        end
    end

end)
local function sweetpig (inst)
	if not inst.components.follower then
		inst:AddComponent("follower")    
	end
	if not inst.components.talker then
		inst:AddComponent("talker")    
	end
	
	if inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("pigprincess") then
	
	local obeychance = math.random(1,9) 
	
		if obeychance ==1 then
		inst.components.talker:Say("Follow you. Forever.")
		elseif obeychance ==2 then
		inst.components.talker:Say("For my princess!")
		elseif obeychance ==3 then
		inst.components.talker:Say("Anything for you!")
		elseif obeychance ==4 then
		inst.components.talker:Say("Daisy. My Princess.")
		elseif obeychance ==5 then
		inst.components.talker:Say("I'm in Love!")
		elseif obeychance ==6 then
		inst.components.talker:Say("DAISY!")		
		return
		end

	return	   
	end
end

AddPrefabPostInit("pigman", function( inst )
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
		inst:DoPeriodicTask(15, sweetpig)
end)


-- The character select screen lines
STRINGS.CHARACTER_TITLES.daisy = "The Pig Princess"
STRINGS.CHARACTER_NAMES.daisy = "Daisy"
STRINGS.CHARACTER_DESCRIPTIONS.daisy = "*Strong bond with pigs\n*May behave like a pig\n*Beware the moon!"
STRINGS.CHARACTER_QUOTES.daisy = "\"Oink.\""

GLOBAL.STRINGS.NAMES.DAISYHAT = "Pig Crown"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.DAISYHAT = "Daisy's Pig Crown"
-- Custom speech strings
STRINGS.CHARACTERS.daisy = require "speech_daisy"

-- The character's name as appears in-game 
STRINGS.NAMES.daisy = "Daisy"

AddMinimapAtlas("images/map_icons/daisy.xml")

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("daisy", "FEMALE")

