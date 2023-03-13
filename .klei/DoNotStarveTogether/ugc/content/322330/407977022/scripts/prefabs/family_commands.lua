RunScript("consolecommands")

function tech()
	c_spawn("researchlab2")
end

function sci()
	c_spawn("researchlab3")
end

function sc()
	c_give("cane")
end

function eq()
	c_give("meatballs",10)
	c_give("ruins_bat")
	c_give("beefalohat")
	c_spawn("firepit")
	c_give("charcoal",20)
	c_give("armorruins")
	c_give("ruinshat")
end

function blu()
	c_give("bluechester_eyebone")
	c_give("nightmarefuel",9)
	c_give("bluegem",9)
end

function dad()
	c_give("bigdaddy_eyebone")
end

function afe()
	c_give("afestertoy")
	c_give("monstermeat",9)
	c_give("spidereggsack",9)
	c_give("lightbulb",9)
end

function dub()
	c_give("partybone")
	c_give("livinglog",9)
	c_give("wetgoop",9)
	c_give("stinger",9)
	c_give("seeds",9)
	c_give("papyrus",9)
	c_give("spear",9)
end

function newmap()
    c_regenerateworld()
end

function speed()
    c_speedmult(2)
end

function map()
    minimap = TheSim:FindFirstEntityWithTag("mini­map")
	TheWorld.minimap.MiniMap:ShowArea (0,0,0,10000)
end

function myblu()
	c_gonext("bluechester_eyebone")
end

function mydad()
	c_gonext("bigdaddy_eyebone")
end

function myafe()
	c_gonext("afestertoy")
end

function mydub()
	c_gonext("partybone")
end

function mycav()
	c_gonext("glowbone")
end
