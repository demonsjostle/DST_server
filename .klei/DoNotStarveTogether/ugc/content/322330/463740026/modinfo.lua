-- This information tells other players more about the mod
name = "Personal Chesters"
description = "Get your very own Chester!"
author = "Dragon Wolf Leo"
version = "1.4"
version_compatible = "1.4"

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""


-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true

-- Not compatible with Don't Starve
dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {
"personalchesters",
}

configuration_options = {
	{
		name = "ownership",
		label = "Ownership Restriction",
		options =
		{
			{description = "Enable", data = true},
			{description = "Disable", data = false}
		},
		default = false,
		hover = "Enable ownership restrictions (requires Ownership mod)",
	},
}