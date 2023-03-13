local assets =
{
	Asset( "ANIM", "anim/daisy.zip" ),
	Asset( "ANIM", "anim/ghost_daisy_build.zip" ),
}

local skins =
{
	normal_skin = "daisy",
	ghost_skin = "ghost_daisy_build",
}

local base_prefab = "daisy"

local tags = {"daisy", "CHARACTER"}

return CreatePrefabSkin("daisy_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	tags = tags,
	
	skip_item_gen = true,
	skip_giftable_gen = true,
})