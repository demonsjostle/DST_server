name = "Chester Family"
description = "fixed"
author = "Kooky with some help from friends"
version = "5.9.6"
forumthread=""
api_version = 10

dst_compatible = true
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
	{
		name = "",
		label = "============================",
			hover = "",
		options =	{
						{description = "============", data = 0},
						{description = "============", data = 1},
						{description = "============", data = 2},
					},
		default = 1,
	},
	
	{
		name = "",
		label = "Choose Your Family",
			hover = "",
		options =	{
						{description = "", data = 0},
					},
		default = 0,
	},
	
	{
		name = "",
		label = "============================",
			hover = "",
		options =	{
						{description = "============", data = 0},
						{description = "============", data = 1},
						{description = "============", data = 2},
					},
		default = 1,
	},
	
	{
		name = "bluester_config",
		label = "Enable Bluester",
		hover = "Bluester is cold and slows food spoilage.",
		options =
	{
		{description = "Enable", data = true, hover = "This will enable Bluester."},
		{description = "Disable", data = false, hover = "This will disable Bluester."},
	},
		default = true,
	},
	
    {
        name = "chilltime",
        label = "Perish Time in Ice Bluster",
        hover = "Here we change the spoilage time of our food.",
        options =
    {
		{description = "Fridge", data = .5, hover = "Makes the freezer the same as icebox"},
		{description = "25", data = .37, hover = "Gives you 25% more time than the icebox"},
		{description = "50", data = .25, hover = "Gives you 50% more time than the icebox"},
		{description = "75", data = .12, hover = "Gives you 75% more time than the icebox"},
		{description = "No Spoilage", data = .01, hover = "With this option slected you will have no spoilage of food."},
	},
		default = .01
    },
	
	{
		name = "",
		label = "------------------------------------------",
			hover = "",
		options =	{
						{description = "------------", data = 0},
						{description = "------------", data = 1},
						{description = "------------", data = 2},
					},
		default = 1,
	},
	
	{
		name = "daddy_config",
		label = "Enable Big Daddy",
		hover = "Big Daddy is a large slow chester that holds more stuff.",
		options =
	{
		{description = "Enable", data = true, hover = "This will enable Big Daddy."},
		{description = "Disable", data = false, hover = "This will disable Big Daddy."},
	},
		default = true,
	},
	
	{
		name = "dubster_config",
		label = "Enable Dubster",
		hover = "Dubster morphs into pinatas that drop tons of items when killed.",
		options =
	{
		{description = "Enable", data = true, hover = "This will enable Dubster."},
		{description = "Disable", data = false, hover = "This will disable Dubster."},
	},
		default = true,
	},
	
	{
		name = "afester_config",
		label = "Enable Afester",
		hover = "Even in his own dimention Afester didn't fit in.",
		options =
	{
		{description = "Enable", data = true, hover = "This will enable Afester."},
		{description = "Disable", data = false, hover = "This will disable Afester."},
	},
		default = true,
	},
	
	{
		name = "cavester_config",
		label = "Enable Cavester",
		hover = "Cavester is all about the underground scene.",
		options =
	{
		{description = "Enable", data = true, hover = "This will enable Cavester."},
		{description = "Disable", data = false, hover = "This will disable Cavester."},
	},
		default = true,
	},
	
	{
		name = "stovester_config",
		label = "Enable Stovester",
		hover = "Stovester likes cooking food.",
		options =
	{
		{description = "Enable", data = true, hover = "This will enable Stovester."},
		{description = "Disable", data = false, hover = "This will disable Stovester."},
	},
		default = true,
	},
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
	{
		name = "",
		label = "============================",
			hover = "",
		options =	{
						{description = "============", data = 0},
						{description = "============", data = 1},
						{description = "============", data = 2},
					},
		default = 1,
	},
	
	{
		name = "",
		label = "Force Spawn Options",
			hover = "",
		options =	{
						{description = "", data = 0},
					},
		default = 0,
	},
	
	{
		name = "",
		label = "============================",
			hover = "",
		options =	{
						{description = "============", data = 0},
						{description = "============", data = 1},
						{description = "============", data = 2},
					},
		default = 1,
	},
	
	{
		name = "force_bluester",
		label = "Force Spawn Bluester",
		hover = "",
		options =
	{
		{description = "Enable", data = true, hover = ""},
		{description = "Disable", data = false, hover = ""},
	},
		default = false,
	},
	
	{
		name = "force_daddy",
		label = "Force Spawn Big Daddy",
		hover = "",
		options =
	{
		{description = "Enable", data = true, hover = ""},
		{description = "Disable", data = false, hover = ""},
	},
		default = false,
	},
	
	{
		name = "force_dubster",
		label = "Force Spawn Dubster",
		hover = "",
		options =
	{
		{description = "Enable", data = true, hover = ""},
		{description = "Disable", data = false, hover = ""},
	},
		default = false,
	},
	
	{
		name = "force_afester",
		label = "Force Spawn Afester",
		hover = "",
		options =
	{
		{description = "Enable", data = true, hover = ""},
		{description = "Disable", data = false, hover = ""},
	},
		default = false,
	},
	
	{
		name = "force_stovester",
		label = "Force Spawn stovester",
		hover = "",
		options =
	{
		{description = "Enable", data = true, hover = ""},
		{description = "Disable", data = false, hover = ""},
	},
		default = false,
	},
	--[[
	{
		name = "force_cavester",
		label = "Force Spawn Cavester",
		hover = "",
		options =
	{
		{description = "Enable", data = true, hover = ""},
		{description = "Disable", data = false, hover = ""},
	},
		default = false,
	},	
	--]]
 }